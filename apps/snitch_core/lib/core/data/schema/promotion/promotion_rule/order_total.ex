defmodule Snitch.Data.Schema.PromotionRule.OrderTotal do
  @moduledoc """
  Models the `promotion rule` based on order total.
  """

  use Snitch.Data.Schema
  use Snitch.Data.Schema.PromotionRule
  alias Snitch.Domain.Order, as: OrderDomain

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

  def rule_name() do
    @name
  end

  @doc """
  Checks if the supplied order meets the criteria of the promotion rule
  `order total`.

  Takes as input the `order` and the `rule_data` which in this case
  is `upper_range` and the `lower_range`. Order total is evaluated against the
  specified ranges. It should fall in between them.

  ### Note
  If the `upper_range` is not set and is 0 then upper_range is ignored and the
  order would be evaluated only against `lower_range`.
  """
  def eligible(order, rule_data) do
    order_total = OrderDomain.total_amount(order)

    if satisfies_rule?(order_total, rule_data) do
      {true, "order satisfies the rule"}
    else
      {false, "order doesn't falls under the item total condition"}
    end
  end

  defp satisfies_rule?(order_total, rule_data) do
    order_total_in_range?(
      order_total,
      Decimal.new(rule_data["lower_range"]),
      Decimal.new(rule_data["upper_range"])
    )
  end

  defp order_total_in_range?(order_total, lower_range, %Decimal{}) do
    currency = order_total.currency
    lower_range = Money.new!(currency, lower_range)

    case Money.cmp(order_total, lower_range) do
      :gt ->
        true

      _ ->
        false
    end
  end

  defp order_total_in_range?(order_total, lower_range, upper_range) do
    currency = order_total.currency
    lower_range = Money.new(currency, lower_range)
    upper_range = Money.new!(currency, upper_range)

    value_lower =
      case Money.cmp(order_total, lower_range) do
        :gt ->
          true

        _ ->
          false
      end

    value_upper =
      case Money.cmp(order_total, upper_range) do
        :lt ->
          true

        _ ->
          false
      end

    value_lower && value_upper
  end
end
