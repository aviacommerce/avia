defmodule AdminAppWeb.ShippingPolicyView do
  use AdminAppWeb, :view

  def rule_button_type(shipping_rule) do
    if shipping_rule.shipping_rule_identifier.code == :fsoa do
      "check"
    else
      "radio"
    end
  end
end
