defmodule Snitch.Domain.Order.Transitions do
  @moduledoc """
  Helpers for the `Order` state machine.

  The `Snitch.Domain.Order.DefaultMachine` makes direct use of these helpers.

  By documenting these handy functions, we encourage the developer of a custom
  state machine to use, extend or compose them to build large event transitions.
  """

  use Snitch.Domain

  alias BeepBop.Context
  alias Snitch.Data.Model.Package
  alias Snitch.Data.Schema.Order
  alias Snitch.Domain.Package, as: PackageDomain

  alias Snitch.Domain.{Shipment, ShipmentEngine, Splitters.Weight}

  @doc """
  Persists the address and associates them with the `order`.

  The following fields are required under the `:state` key:
  * `:billing_address` The billing `Address` params
  * `:shipping_address` The shipping `Address` params

  ## Note
  This transition is "impure" as it does not use the multi, the addresses are
  associated "out-of-band".
  """
  @spec associate_address(Context.t()) :: Context.t()
  def associate_address(
        %Context{
          valid?: true,
          struct: %Order{} = order,
          state: %{
            billing_address: billing,
            shipping_address: shipping
          }
        } = context
      ) do
    order
    |> Order.partial_update_changeset(%{billing_address: billing, shipping_address: shipping})
    |> Repo.update()
    |> case do
      {:ok, order} ->
        Context.new(order, state: context.state)

      errors ->
        struct(context, valid?: false, errors: errors)
    end
  end

  def associate_address(%Context{} = context), do: struct(context, valid?: false)

  @doc """
  Computes a shipment fulfilling the `order`.

  Returns a new `Context.t` struct with the `shipment` under the the [`:state`,
  `:shipment`] key-path.

  > The `:state` key of the `context` is not utilised here.

  ## Note

  If `shipment` is `[]`, we mark the `context` "invalid" because we could not
  find any shipment.
  """
  @spec compute_shipments(Context.t()) :: Context.t()
  # TODO: This function does not gracefully handle errors, they are raised!
  def compute_shipments(
        %Context{
          valid?: true,
          struct: %Order{} = order
        } = context
      ) do
    order
    |> Shipment.default_packages()
    |> ShipmentEngine.run(order)
    |> Weight.split()
    |> case do
      [] ->
        struct(
          context,
          valid?: false,
          state: %{shipment: []},
          errors: {:error, "no shipment possible"}
        )

      shipment ->
        struct(context, state: %{shipment: shipment})
    end
  end

  def compute_shipments(%Context{valid?: false} = context), do: context

  @doc """
  Persists the computed shipment to the DB.

  `Package`s and their `PackageItem`s are inserted together in a DB transaction.

  Returns a new `Context.t` struct with the `shipment` under the the [`:state`,
  `:shipment`] key-path.

  In case of any errors, an invalid Context struct is returned, with the error
  under the `:multi`.
  """
  @spec persist_shipment(Context.t()) :: Context.t()
  def persist_shipment(%Context{valid?: true, struct: %Order{} = order} = context) do
    %{state: %{shipment: shipment}, multi: multi} = context

    function = fn _ ->
      shipment
      |> Stream.map(&Shipment.to_package(&1, order))
      |> Stream.map(&Package.create/1)
      |> fail_fast_reduce()
    end

    struct(context, multi: Multi.run(multi, :packages, function))
  end

  def persist_shipment(%Context{valid?: false} = context), do: context

  @doc """
  Persists the shipping preferences of the user in each `package` of the `order`.

  Along with the chosen `ShippingMethod`, we update pacakge price fields. User's
  selection is assumed to be under the `context.state.shipping_preferences` key-path.

  ## Schema of the `:state`
  ```
  %{
    shipping_preferences: [
      %{
        package_id: string,
        shipping_method_id: non_neg_integer
      }
    ]
  }
  ```

  ## Assumptions
  * For each `package` of the `order`, a valid `shipping_method` must be chosen.
    > If an `order` has 3 packages, then
      `length(context.state.shipping_preferences)` must be `3`.
  * The chosen `shipping_method` for the `package` must be one among the
    `package.shipping_methods`.
  """
  @spec persist_shipping_preferences(Context.t()) :: Context.t()
  def persist_shipping_preferences(%Context{valid?: true, struct: %Order{} = order} = context) do
    %{state: %{shipping_preferences: shipping_preferences}, multi: multi} = context

    packages = Map.fetch!(Repo.preload(order, [:packages]), :packages)

    if validate_shipping_preferences(packages, shipping_preferences) do
      function = fn _ ->
        shipping_preferences
        |> Stream.map(fn %{package_id: package_id, shipping_method_id: shipping_method_id} ->
          packages
          |> Enum.find(fn %{id: id} -> id == package_id end)
          |> PackageDomain.set_shipping_method(shipping_method_id)
        end)
        |> fail_fast_reduce()
      end

      struct(context, multi: Multi.run(multi, :packages, function))
    else
      struct(context, valid?: false, errors: [shipping_preferences: "is invalid"])
    end
  end

  defp validate_shipping_preferences([], _), do: true

  defp validate_shipping_preferences(packages, selection) do
    # selection must be over all packages, no package can be skipped.
    # TODO: Replace with some nice API contract/validator.
    package_ids =
      packages
      |> Enum.map(fn %{id: id} -> id end)
      |> MapSet.new()

    selection
    |> Enum.map(fn %{package_id: p_id} -> p_id end)
    |> MapSet.new()
    |> MapSet.equal?(package_ids)
  end

  defp fail_fast_reduce(things) do
    Enum.reduce_while(things, {:ok, []}, fn
      {:ok, thing}, {:ok, acc} ->
        {:cont, {:ok, [thing | acc]}}

      {:error, _} = error, _ ->
        {:halt, error}
    end)
  end
end
