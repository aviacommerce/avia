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
      |> Enum.reduce_while({:ok, []}, fn
        {:ok, package}, {:ok, acc} ->
          {:cont, {:ok, [package | acc]}}

        {:error, _} = error, _ ->
          {:halt, error}
      end)
    end

    struct(context, multi: Multi.run(multi, :packages, function))
  end

  def persist_shipment(%Context{valid?: false} = context), do: context

  @doc """
  Persists shipping_method_id to packages

  Calculate pacakge total cost Sum(shipping_cost, adjustment_total,promo_total, shipping_cost)

  Update package cost total in DB
  """

  @spec associate_package(Context.t()) :: Context.t()
  def associate_package(%Context{valid?: true, struct: %Order{} = order} = context) do
    %{state: %{packages: packages}, multi: multi} = context

    function = fn _ ->
      packages
      |> Stream.map(&process_package/1)
      |> Enum.reduce_while({:ok, []}, fn
        {:ok, package}, {:ok, acc} ->
          {:cont, {:ok, [package | acc]}}

        {:error, _} = error, _ ->
          {:halt, error}
      end)
    end

    struct(context, multi: Multi.run(multi, :packages, function))
  end

  defp extract_shipping_method_cost(package) do
    sm =
      Enum.find(package.shipping_methods, fn %{shipping_method_id: id} ->
        id == package.shipping_method_id
      end)

    sm.cost
  end

  defp calculate_package_total(
         %{tax_total: tax_total, adjustment_total: adjustment_total, promo_total: promo_total},
         shipping_cost
       ) do
    Enum.reduce([tax_total, adjustment_total, promo_total, shipping_cost], &Money.add!/2)
  end

  defp process_package(package) do
    shipping_cost = extract_shipping_method_cost(package)
    package_total = calculate_package_total(package, shipping_cost)

    IO.inspect({shipping_cost, package_total}, label: "costs")
    Package.update(package, %{cost: shipping_cost, total: package_total})
  end
end
