defmodule Snitch.Data.Model.ShippingRuleTest do
  use ExUnit.Case
  use Snitch.DataCase

  import Snitch.Factory

  alias Snitch.Data.Model.ShippingRule

  setup do
    shipping_rule = insert(:shipping_rule)
    [shipping_rule: shipping_rule]
  end

  test "get_all/0 returns all shipping_rules", %{shipping_rule: shipping_rule} do
    shipping_rules = ShippingRule.get_all()
    assert shipping_rules != []
  end

  describe "get/1" do
    test "returns shipping_rule with valid id", %{shipping_rule: shipping_rule} do
      {:ok, new_shipping_rule} = ShippingRule.get(shipping_rule.id)

      assert new_shipping_rule.id == shipping_rule.id
    end

    test "fails for invalid id" do
      assert {:error, :shipping_rule_not_found} = ShippingRule.get(-1)
    end
  end

  describe "get_all_by_shipping_category/1" do
    test "returns a shipping_rule", %{shipping_rule: shipping_rule} do
      id = shipping_rule.shipping_category_id
      [new_shipping_rule] = ShippingRule.get_all_by_shipping_category(id)
      assert new_shipping_rule.id == shipping_rule.id
    end

    test "returns an empty list" do
      new_shipping_rule = ShippingRule.get_all_by_shipping_category(-1)
      assert new_shipping_rule == []
    end
  end
end
