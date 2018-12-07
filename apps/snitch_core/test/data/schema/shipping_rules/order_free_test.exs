defmodule Snitch.Data.Schema.ShippingRule.OrderFreeTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase
  import Snitch.Factory
  alias Snitch.Core.Tools.MultiTenancy.Repo
  alias Snitch.Data.Schema.ShippingRule
  alias Snitch.Data.Schema.ShippingRule.OrderFree

  @params %{
    preferences: %{},
    active?: false
  }

  describe "create shipping rule type 'free shipping for order'" do
    test "successfully" do
      shipping_category = insert(:shipping_category)

      shipping_identifier =
        insert(:shipping_identifier, code: :fso, description: "free shipping for order")

      params =
        @params
        |> Map.put(:shipping_category_id, shipping_category.id)
        |> Map.put(:shipping_rule_identifier_id, shipping_identifier.id)

      changeset = ShippingRule.changeset(%ShippingRule{}, params)
      assert {:ok, _data} = Repo.insert(changeset)
    end
  end

  describe "calculate/3" do
    setup :zones
    setup :shipping_methods
    setup :embedded_shipping_methods

    test "returns {:halt, cost} for free shipping for all orders", context do
      rule_manifest = %{code: :fso, description: "free shipping for order"}
      preference_manifest = %{}

      %{package: package, rule: rule} =
        package_with_shipping_rule(context, 3, rule_manifest, preference_manifest)

      assert {:halt, cost} =
               OrderFree.calculate(package, currency(), rule, Money.new!(currency(), 0))

      assert cost == Money.new!(currency(), 0)
    end
  end

  test "identifier is :fso" do
    assert :fso == OrderFree.identifier()
  end
end
