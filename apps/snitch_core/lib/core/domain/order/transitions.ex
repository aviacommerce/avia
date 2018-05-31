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
  alias Snitch.Data.Model.Order, as: OrderModel
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
  def associate_address(%Context{valid?: true, struct: %Order{} = order} = context) do
    context
    |> address_insert_multi()
    |> Repo.transaction()
    |> case do
      {:ok, %{order: order, billing: billing, shipping: shipping}} ->
        Context.new(order, state: %{billing: billing, shipping: shipping})

      {:error, errors} ->
        Context.new(order, valid?: false, state: context.state, multi: errors)
    end
  end

  def associate_address(%Context{valid?: false} = context), do: context

  @doc """
  Computes a shipment fulfilling the `order`.

  Returns a new `Context.t` struct with the `shipment` under the the [`:state`,
  `:shipment`] key-path.

  > The `:state` key of the `context` is not utilised here.

  ## Note

  The validity of the returned context is the same as the `context` passed
  in.
  This means we do NOT mark the `context` "invalid" even if `shipment` is `[]`
  (we could not find any shipment).
  """
  @spec compute_shipments(Context.t()) :: Context.t()
  # TODO: This function does not gracefully handle errors, they are raised!
  def compute_shipments(%Context{valid?: true, state: state, struct: %Order{} = order} = context) do
    shipment =
      order
      |> Shipment.default_packages()
      |> ShipmentEngine.run(order)
      |> Weight.split()

    struct(context, state: Map.put(state, :shipment, shipment))
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

  defp address_insert_multi(context) do
    %{
      struct: %Order{} = order,
      state: %{billing_cs: %Changeset{} = billing_cs, shipping_cs: %Changeset{} = shipping_cs},
      multi: multi
    } = context

    old_line_items = Enum.map(order.line_items, &Map.from_struct/1)

    multi
    |> Multi.insert(:billing, billing_cs)
    |> Multi.insert(:shipping, shipping_cs)
    |> Multi.run(:order, fn %{billing: b, shipping: s} ->
      OrderModel.update(
        %{billing_address_id: b.id, shipping_address_id: s.id, line_items: old_line_items},
        order
      )
    end)
  end
end
