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
    test "successfully", context do
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

  test "identifier is :fsrp" do
    assert :fsrp == ProductFlatRate.identifier()
  end
end
