defmodule Snitch.Data.Schema.ShippingRule.ProductFlatRateTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase
  import Snitch.Factory
  alias Snitch.Core.Tools.MultiTenancy.Repo
  alias Snitch.Data.Schema.ShippingRule
  alias Snitch.Data.Schema.ShippingRule.ProductFlatRate

  @params %{
    preferences: %{cost_per_item: 0.00},
    active?: false
  }

  describe "create shipping rule type 'fixed shipping rate per product'" do
    test "successfully" do
      shipping_category = insert(:shipping_category)

      shipping_identifier =
        insert(:shipping_identifier, code: :fsrp, description: "fixed shipping rate per product")

      params =
        @params
        |> Map.put(:shipping_category_id, shipping_category.id)
        |> Map.put(:shipping_rule_identifier_id, shipping_identifier.id)

      changeset = ShippingRule.changeset(%ShippingRule{}, params)
      assert {:ok, _data} = Repo.insert(changeset)
    end

    test "fails for invalid cost_per_item" do
      shipping_category = insert(:shipping_category)

      shipping_identifier =
        insert(:shipping_identifier, code: :fsrp, description: "fixed shipping rate per product")

      params =
        @params
        |> Map.put(:shipping_category_id, shipping_category.id)
        |> Map.put(:shipping_rule_identifier_id, shipping_identifier.id)
        |> Map.put(:preferences, %{cost_per_item: "abc"})

      changeset = ShippingRule.changeset(%ShippingRule{}, params)
      assert {:error, changeset} = Repo.insert(changeset)
      assert %{preferences: ["cost_per_item is invalid. "]} = errors_on(changeset)
    end
  end

  describe "calculate/3" do
    setup :zones
    setup :shipping_methods
    setup :embedded_shipping_methods

    test "returns {:cont, cost} for flat cost per product", context do
      rule_manifest = %{code: :fsrp, description: "fixed shipping rate per product"}
      preference_manifest = %{cost_per_item: Decimal.new(10.00)}

      %{package: package, rule: rule} =
        package_with_shipping_rule(context, 3, rule_manifest, preference_manifest)

      assert {:cont, cost} =
               ProductFlatRate.calculate(package, currency(), rule, Money.new!(currency(), 0))

      currency = currency()

      assert cost ==
               currency
               |> Money.new!(Decimal.new(10.00))
               |> Money.mult!(3)
               |> Money.round()
    end
  end

  test "identifier is :fsrp" do
    assert :fsrp == ProductFlatRate.identifier()
  end
end
