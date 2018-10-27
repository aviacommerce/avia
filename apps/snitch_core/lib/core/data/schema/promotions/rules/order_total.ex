defmodule Snitch.Data.Schema.PromotionRule.OrderTotal do
  @moduledoc false

  use Snitch.Data.Schema

  alias Snitch.Domain.Order, as: OrderDomain

  embedded_schema do
    field(:lower_range, :decimal, default: 0.0)
    field(:upper_range, :decimal, default: 0.0)
  end

  def changeset(%__MODULE__{} = data, params) do
    data
    |> cast(params, [:lower_range, :upper_range])
  end

  def eligible(order, rule_data) do
    order_total = OrderDomain.total_amount(order)
    {true, "order satisfies the rule"}
  end
end
