defmodule Snitch.Data.Model.ShippingCategoryTest do
  @moduledoc false

  use ExUnit.Case
  use Snitch.DataCase
  import Snitch.Factory
  alias Snitch.Data.Model.ShippingCategory
  alias Snitch.Data.Schema.ShippingCategory, as: ScSchema

  describe "update/2" do
    test "update shippping rules for category" do
      shipping_category = insert(:shipping_category)
      %{rules: [rule_1, rule_2]} = setup_category_rules(shipping_category)

      shipping_category =
        ScSchema
        |> Repo.get(shipping_category.id)
        |> Repo.preload(:shipping_rules)

      assert rule_1.active? == true
      assert rule_2.active? == false

      params = %{
        shipping_rules: [
          %{id: rule_1.id, active?: false, preferences: %{amount: Decimal.new(10)}},
          %{id: rule_2.id, active?: true, shipping_cost: %{amount: Decimal.new(10)}}
        ]
      }

      {:ok, sc} = ShippingCategory.update(params, shipping_category)
      sc = Repo.preload(sc, :shipping_rules)

      rule_1 = Enum.find(sc.shipping_rules, fn rule -> rule.id == rule_1.id end)
      assert rule_1.active? == false
      assert rule_1.preferences.amount == Decimal.new(10)
    end
  end

  defp setup_category_rules(shipping_category) do
    shipping_identifier_1 =
      insert(:shipping_identifier,
        code: :fsoa,
        description: "free shipping for order above"
      )

    shipping_identifier_2 =
      insert(:shipping_identifier,
        code: :ofr,
        description: "fixed shipping rate for all orders"
      )

    shipping_rule_1 =
      insert(:shipping_rule,
        active?: true,
        preferences: %{amount: Decimal.new(20)},
        shipping_rule_identifier: shipping_identifier_1,
        shipping_category: shipping_category
      )

    shipping_rule_2 =
      insert(:shipping_rule,
        active?: false,
        preferences: %{cost: Decimal.new(10)},
        shipping_rule_identifier: shipping_identifier_2,
        shipping_category: shipping_category
      )

    %{rules: [shipping_rule_1, shipping_rule_2]}
  end
end
