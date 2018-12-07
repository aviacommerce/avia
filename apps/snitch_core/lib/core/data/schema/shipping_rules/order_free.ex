defmodule Snitch.Data.Schema.ShippingRule.OrderFree do
  @moduledoc """
  Models the shipping rule of the type OrderFree

  In case the rule is activated for shipping the shipping cost
  will be zero.
  """

  use Snitch.Data.Schema

  @behaviour Snitch.Data.Schema.ShippingRule

  @identifier :fso
  @description "free shipping for order"

  embedded_schema do
  end

  def changeset(%__MODULE__{} = data, params \\ %{}) do
    change(data, params)
  end

  def calculate(_package, currency_code, _rule, _prev_cost) do
    {:halt, Money.new!(currency_code, 0)}
  end

  def identifier() do
    @identifier
  end

  def description() do
    @description
  end
end
