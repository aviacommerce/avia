defmodule AdminAppWeb.ShippingPolicyView do
  use AdminAppWeb, :view
  alias Snitch.Data.Schema.ShippingRuleIdentifier

  def check_identifier(:product, shipping_rule) do
    product_identifers = ShippingRuleIdentifier.product_identifier()
    shipping_rule.shipping_rule_identifier.code in product_identifers
  end

  def check_identifier(:order, shipping_rule) do
    order_identifers = ShippingRuleIdentifier.order_identifiers()
    shipping_rule.shipping_rule_identifier.code in order_identifers
  end

  def show_amount(money) do
    money = money |> Money.round()
    money.amount
  end
end
