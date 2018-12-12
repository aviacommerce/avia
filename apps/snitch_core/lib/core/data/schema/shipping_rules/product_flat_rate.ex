defmodule Snitch.Data.Schema.ShippingRule.ProductFlatRate do
  @moduledoc """
  Models the shipping rule of the type ProductFlatRate

  In case the rule is activated for shipping all the lineitems will have a
  fixed shipping rate applied to them.
  """

  use Snitch.Data.Schema

  @behaviour Snitch.Data.Schema.ShippingRule

  @identifier :fsrp
  @description "fixed shipping rate per product"

  embedded_schema do
    field(:cost_per_item, :decimal)
  end

  def changeset(%__MODULE__{} = data, params) do
    data
    |> cast(params, [:cost_per_item])
  end

  def calculate(package, currency_code, rule, _prev_cost) do
    all_products =
      Enum.reduce(package.items, 0, fn item, acc ->
        acc + item.quantity
      end)

    cost_per_item = Money.new!(currency_code, rule.preferences["cost_per_item"])

    {:cont,
     cost_per_item
     |> Money.mult!(all_products)
     |> Money.round()}
  end

  def identifier() do
    @identifier
  end

  def description() do
    @description
  end
end
