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

  def changeset(_, _) do
    %{}
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
