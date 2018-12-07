defmodule Snitch.Data.Schema.ShippingRule.OrderFlatRateTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase
  import Snitch.Factory
  alias Snitch.Core.Tools.MultiTenancy.Repo
  alias Snitch.Data.Schema.ShippingRule
  alias Snitch.Data.Schema.ShippingRule.OrderFlatRate

  @params %{
    preferences: %{cost: 0.00},
    active?: false
  }

  describe "create shipping rule type 'fixed shipping rate for order'" do
    test "successfully", context do
      shipping_category = insert(:shipping_category)

      shipping_identifier =
        insert(:shipping_identifier, code: :ofr, description: "fixed shipping rate for order")

      params =
        @params
        |> Map.put(:shipping_category_id, shipping_category.id)
        |> Map.put(:shipping_rule_identifier_id, shipping_identifier.id)

      changeset = ShippingRule.changeset(%ShippingRule{}, params)
      assert {:ok, _data} = Repo.insert(changeset)
    end

    test "fails for invalid cost" do
      shipping_category = insert(:shipping_category)

      shipping_identifier =
        insert(:shipping_identifier, code: :ofr, description: "fixed shipping rate for order")

      params =
        @params
        |> Map.put(:shipping_category_id, shipping_category.id)
        |> Map.put(:shipping_rule_identifier_id, shipping_identifier.id)
        |> Map.put(:preferences, %{cost: "abc"})

      changeset = ShippingRule.changeset(%ShippingRule{}, params)
      assert {:error, changeset} = Repo.insert(changeset)
      assert %{preferences: ["cost is invalid. "]} = errors_on(changeset)
    end
  end

  test "identifier is :ofr" do
    assert :ofr == OrderFlatRate.identifier()
  end
end
