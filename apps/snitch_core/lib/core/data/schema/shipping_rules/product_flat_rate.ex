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

  def calculate(_package, currency_code, _rule) do
    Money.new!(currency_code, 0)
  end

  def identifier() do
    @identifier
  end

  def description() do
    @description
  end
end
