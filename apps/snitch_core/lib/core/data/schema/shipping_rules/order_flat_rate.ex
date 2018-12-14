defmodule Snitch.Data.Schema.ShippingRule.OrderFlatRate do
  @moduledoc """
  Models the shipping rule of the type OrderFlatRate

  In case the rule is activated for shipping all the orders will have a
  fixed shipping rate applied to them.
  """

  use Snitch.Data.Schema

  @behaviour Snitch.Data.Schema.ShippingRule

  @identifier :ofr
  @description "fixed shipping rate for order"

  embedded_schema do
    field(:cost, :decimal)
  end

  def changeset(%__MODULE__{} = data, params) do
    data
    |> cast(params, [:cost])
  end

  def calculate(_package, currency_code, rule, _prev_cost) do
    {:cont, Money.new!(currency_code, rule.preferences["cost"])}
  end

  def identifier() do
    @identifier
  end

  def description() do
    @description
  end
end
