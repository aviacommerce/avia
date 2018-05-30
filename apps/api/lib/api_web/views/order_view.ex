defmodule ApiWeb.OrderView do
  use ApiWeb, :view

  def render("new.json", %{order: order}) do
    %{
      id: order.id,
      number: order.id,
      item_total: order.item_total.amount,
      total: order.total.amount,
      ship_total: "0.0",
      state: order.state,
      adjustment_total: order.adjustment_total.amount,
      user_id: order.user_id,
      created_at: order.inserted_at,
      updated_at: order.updated_at,
      completed_at: nil,
      payment_total: "0.0",
      shipment_state: nil,
      payment_state: nil,
      email: nil,
      token: order.id,
      bill_address: nil,
      ship_address: nil,
      line_items: order.line_items,
      currency: order.total.currency,
      payments: []
    }
  end

  def render("current.json", _params) do
    nil
  end
end
