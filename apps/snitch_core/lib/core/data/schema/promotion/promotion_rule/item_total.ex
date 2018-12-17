defmodule Snitch.Data.Schema.PromotionRule.ItemTotal do
  @moduledoc """
  Models the `promotion rule` based on order total.
  """

  use Snitch.Data.Schema
  alias Snitch.Domain.Order, as: OrderDomain

  @behaviour Snitch.Data.Schema.PromotionRule
  @type t :: %__MODULE__{}
  @name "Order Item Total"

  embedded_schema do
    field(:lower_range, :decimal, default: 0.0)
    field(:upper_range, :decimal, default: 0.0)
  end

  def changeset(%__MODULE__{} = data, params) do
    data
    |> cast(params, [:lower_range, :upper_range])
  end

  @doc """
  Checks if the supplied order meets the criteria of the promotion rule.
  Takes as input the `order` and the data `rule_data` which in this case
  is upper and the lower range against which the order total would be
  evaluated.
  """
  def eligible(order, rule_data) do
    order_total = OrderDomain.total_amount(order)

    if satisfies_rule?(order_total, rule_data) do
      {true, "order satisfies the rule"}
    else
      {false, "order doesn't falls under the range"}
    end
  end

  defp satisfies_rule?(order_total, rule) do
    # TODO add the logic here
  end

  def rule_name() do
    @name
  end
end
