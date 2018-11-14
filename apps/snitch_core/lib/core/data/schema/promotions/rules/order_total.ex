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

  # TODO need to add rule for upper_range
  defp satisfies_rule?(order_total, rule_data) do
    lower_range = Money.new!(:USD, rule_data.lower_range)

    case Money.compare!(order_total, lower_range) do
      1 ->
        true

      _ ->
        false
    end
  end
end
