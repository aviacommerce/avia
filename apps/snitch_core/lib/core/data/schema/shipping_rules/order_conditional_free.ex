defmodule Snitch.Data.Schema.ShippingRule.OrderConditionalFree do
  @moduledoc """
  Models the shipping rule in which free shipping is available conditionally
  for an order.

  For this shipping rule if an order is above certain amount the shipping cost
  would be zero. This rule is usually applied along with another rule such as
  fixed shipping rate for an order or fixed shipping rate per product for an
  order.
  """
  use Snitch.Data.Schema
  alias Snitch.Data.Schema.Order
  alias Snitch.Domain.Order, as: OrderDomain

  @behaviour Snitch.Data.Schema.ShippingRule

  @identifier :fsoa
  @description "free shipping above specified amount"

  embedded_schema do
    field(:amount, :decimal)
  end

  def changeset(%__MODULE__{} = data, params) do
    data
    |> cast(params, [:amount])
  end

  def calculate(package, currency_code, rule, prev_cost) do
    order = Repo.get(Order, package.order_id) |> Repo.preload(:line_items)
    total_order_cost = OrderDomain.line_item_total(order)

    min_amount = Money.new!(currency_code, rule.preferences["amount"])

    if Money.cmp!(min_amount, total_order_cost) == :lt do
      {:halt, Money.new!(currency_code, 0)}
    else
      {:cont, prev_cost}
    end
  end

  def identifier() do
    @identifier
  end

  def description() do
    @description
  end
end
