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

  def check_identifier(:free, shipping_rule) do
    identifiers = ShippingRuleIdentifier.free_identifiers()
    shipping_rule.shipping_rule_identifier.code in identifiers
  end

  def show_amount(money) do
    money = money |> Money.round()
    money.amount
  end

  ## TODO: handle the requirement gracefully for showing description
  def identfier_detail(code) do
    ShippingRuleIdentifier.identifer_description(code)
  end
end
