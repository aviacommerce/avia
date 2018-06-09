defmodule Snitch.Domain.Order.Transitions do
  @moduledoc """
  Helpers for the `Order` state machine.

  The `Snitch.Domain.Order.DefaultMachine` makes direct use of these helpers.

  By documenting these handy functions, we encourage the developer of a custom
  state machine to use, extend or compose them to build large event transitions.
  """

  use Snitch.Domain

  alias Ecto.Changeset
  alias BeepBop.Context
  alias Snitch.Data.Model.Package
  alias Snitch.Data.Schema.Order
  alias Snitch.Domain.{Shipment, ShipmentEngine, Splitters.Weight}

  @doc """
  Persists the address changesets and associates them with the `order`.

  The following fields are required under the `:state` key:
  * `:billing_cs` The billing `Address` changeset (will be inserted).
  * `:shipping_cs` The shipping `Address` changeset (will be inserted).

  Returns a new `Context.t` struct with the updated `Order` struct.
  The `:state` is reset to `nil`.

  In case of any errors, the `context` is marked "invalid" and errors are put
  under the `:multi` key.

  ## Note
  > _This transition is "impure"!_

  The addresses are persisted to the DB (and associated with the `order`)
  irrespective of the result of the full event transition.
  """
  @spec associate_address(Context.t()) :: Context.t()
  def associate_address(
        %Context{
          valid?: true,
          struct: %Order{} = order,
          state: %{
            billing_address: billing,
            shipping_address: shipping
          },
          multi: multi
        } = context
      ) do
    order = Repo.preload(order, [:billing_address, :shipping_address])

    multi =
      Multi.update(
        multi,
        :order,
        Order.partial_update_changeset(order, %{
          billing_address: billing,
          shipping_address: shipping
        })
      )

    struct(context, struct: order, multi: multi)
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
          struct: order,
          state: %{
            shipping_address: %Changeset{} = address
          }
        } = context
      ) do
    order
    |> struct(shipping_address: Changeset.apply_changes(address))
    |> Shipment.default_packages()
    |> ShipmentEngine.run(order)
    |> Weight.split()
    |> case do
      [] ->
        struct(context, valid?: false, state: %{shipment: []})

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
end
