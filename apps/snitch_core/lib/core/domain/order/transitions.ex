defmodule Snitch.Domain.Order.Transitions do
  use Snitch.Domain

  alias Ecto.Changeset
  alias BeepBop.Context
  alias Model.Order, as: OrderModel

  def associate_address(%Context{} = state) do
    %{
      struct: order,
      state: %{billing_cs: %Changeset{} = billing_cs, shipping_cs: %Changeset{} = shipping_cs},
      multi: multi
    } = state

    old_line_items = Enum.map(order.line_items, &Map.from_struct/1)

    with_address_multi =
      multi
      |> Multi.insert(:billing, billing_cs)
      |> Multi.insert(:shipping, shipping_cs)
      |> Multi.run(:order, fn %{billing: b, shipping: s} ->
        OrderModel.update(
          %{billing_address_id: b.id, shipping_address_id: s.id, line_items: old_line_items},
          order
        )
      end)

    struct(state, multi: with_address_multi)
  end

  def compute_shipments(%Context{} = state) do
    state
  end

  def process_payment(%Context{} = state) do
    state
  end
end
