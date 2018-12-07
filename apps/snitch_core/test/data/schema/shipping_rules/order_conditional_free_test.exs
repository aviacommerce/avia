defmodule Snitch.Data.Schema.ShippingRule.OrderConditionalFreeTest do
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
    test "successfully", context do
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
end
