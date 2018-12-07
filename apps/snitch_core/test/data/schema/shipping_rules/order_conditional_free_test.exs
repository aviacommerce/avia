defmodule Snitch.Data.Schema.ShippingRule.OrderConditionalFreeTest do
  @moduledoc false

  use ExUnit.Case, async: true
  use Snitch.DataCase
  import Snitch.Factory
  alias Snitch.Core.Tools.MultiTenancy.Repo
  alias Snitch.Data.Schema.ShippingRule
  alias Snitch.Data.Schema.ShippingRule.OrderConditionalFree

  @params %{
    preferences: %{amount: 0.00},
    active?: false
  }

  describe "create shipping rule type 'free for above some amount'" do
    test "successfully" do
      shipping_category = insert(:shipping_category)

      shipping_identifier =
        insert(:shipping_identifier, code: :fsoa, description: "free shipping above amount")

      params =
        @params
        |> Map.put(:shipping_category_id, shipping_category.id)
        |> Map.put(:shipping_rule_identifier_id, shipping_identifier.id)

      changeset = ShippingRule.changeset(%ShippingRule{}, params)
      assert {:ok, _data} = Repo.insert(changeset)
    end

    test "fails for invalid amount" do
      shipping_category = insert(:shipping_category)

      shipping_identifier =
        insert(:shipping_identifier,
          code: :fsoa,
          description: "free shipping above amount"
        )

      params =
        @params
        |> Map.put(:shipping_category_id, shipping_category.id)
        |> Map.put(:shipping_rule_identifier_id, shipping_identifier.id)
        |> Map.put(:preferences, %{amount: "abc"})

      changeset = ShippingRule.changeset(%ShippingRule{}, params)
      assert {:error, changeset} = Repo.insert(changeset)
      assert %{preferences: ["amount is invalid. "]} = errors_on(changeset)
    end
  end

  test "identifier is :fsoa" do
    assert :fsoa == OrderConditionalFree.identifier()
  end

  describe "calculate/3" do
    setup :zones
    setup :shipping_methods
    setup :embedded_shipping_methods

    test "order meets the condition and return is {:halt, cost}", context do
      # if free shipping for order above some amount is applied
      # it overrides cost set by rule set along with it return is {:halt, cost}

      rule_manifest = %{code: :fsoa, description: "free shipping above amount"}
      preference_manifest = %{amount: 20}

      %{package: package, rule: rule} =
        package_with_shipping_rule(context, 3, rule_manifest, preference_manifest)

      assert {:halt, cost} =
               OrderConditionalFree.calculate(
                 package,
                 currency(),
                 rule,
                 Money.new!(currency(), 0)
               )
    end

    test "order does not meet condition and return is {:cont, cost}", context do
      # if free shipping for order above some amount is not applied
      # it returns {:cont, cost}

      rule_manifest = %{code: :fsoa, description: "free shipping above amount"}
      preference_manifest = %{amount: 20}

      %{package: package, rule: rule} =
        package_with_shipping_rule(context, 1, rule_manifest, preference_manifest)

      assert {:cont, cost} =
               OrderConditionalFree.calculate(
                 package,
                 currency(),
                 rule,
                 Money.new!(currency(), 0)
               )
    end
  end
end
