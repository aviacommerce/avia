defmodule Snitch.Data.Schema.PromotionRule.ProductTest do
  @moduledoc false

  use ExUnit.Case
  use Snitch.DataCase
  import Snitch.Factory
  alias Snitch.Data.Schema.PromotionRule.Product, as: ProductRule
  alias Snitch.Data.Schema.PromotionRule

  @success_message "product rule applies for order"
  @failure_messsage "product rule fails for the order"

  setup do
    products = insert_list(3, :product, %{promotionable: true})
    order = insert(:order, state: :delivery)

    [line_items: line_items] =
      line_items(%{order: order, variants: products, line_item_count: length(products)})

    order = Repo.preload(order, line_items: :product)

    [order: order, products: products, line_items: line_items]
  end

  describe "eligible with match_policy 'all'" do
    test "returns true as order has all of the products", context do
      %{order: order, products: products} = context
      product_list = Enum.map(products, fn p -> p.id end)

      rule =
        insert(:product_rule,
          preferences: %{match_policy: "all", product_list: product_list}
        )

      promotion = Repo.preload(rule.promotion, :rules)
      [rule] = promotion.rules

      assert {true, message} = ProductRule.eligible(order, rule.preferences)
      assert message == @success_message
    end

    test "returns false as order does not contain all products", context do
      %{order: order, products: products} = context
      new_product = insert(:product)
      product_list = [new_product.id | Enum.map(products, fn p -> p.id end)]

      rule =
        insert(:product_rule,
          preferences: %{match_policy: "all", product_list: product_list}
        )

      promotion = Repo.preload(rule.promotion, :rules)
      [rule] = promotion.rules

      assert {false, message} = ProductRule.eligible(order, rule.preferences)
      assert message == @failure_messsage
    end
  end

  describe "eligible with match_policy 'any'" do
    test "returns true as order has some of the products", context do
      %{order: order, products: products} = context
      new_product = insert(:product)
      product_list = [new_product.id | Enum.map(products, fn p -> p.id end)]

      rule =
        insert(:product_rule,
          preferences: %{match_policy: "any", product_list: product_list}
        )

      promotion = Repo.preload(rule.promotion, :rules)
      [rule] = promotion.rules

      assert {true, message} = ProductRule.eligible(order, rule.preferences)
      assert message == @success_message
    end

    test "returns false as order does not have any of the products", context do
      %{order: order} = context
      new_product = insert(:product)
      product_list = [new_product.id]

      rule =
        insert(:product_rule,
          preferences: %{match_policy: "any", product_list: product_list}
        )

      promotion = Repo.preload(rule.promotion, :rules)
      [rule] = promotion.rules

      assert {false, message} = ProductRule.eligible(order, rule.preferences)
      assert message == @failure_messsage
    end
  end

  describe "eligible with match_policy 'none'" do
    test "returns true as order does not have any of the products", context do
      %{order: order} = context
      new_product = insert(:product)
      product_list = [new_product.id]

      rule =
        insert(:product_rule,
          preferences: %{match_policy: "none", product_list: product_list}
        )

      promotion = Repo.preload(rule.promotion, :rules)
      [rule] = promotion.rules

      assert {true, message} = ProductRule.eligible(order, rule.preferences)
      assert message == @success_message
    end

    test "returns false as order has some of the products", context do
      %{order: order, products: products} = context
      new_product = insert(:product)
      product_list = [new_product.id | Enum.map(products, fn p -> p.id end)]

      rule =
        insert(:product_rule,
          preferences: %{match_policy: "none", product_list: product_list}
        )

      promotion = Repo.preload(rule.promotion, :rules)
      [rule] = promotion.rules

      assert {false, message} = ProductRule.eligible(order, rule.preferences)
      assert message == @failure_messsage
    end
  end

  describe "line_item_actionable?/2" do
    test "returns true for match policy 'all'", context do
      %{products: products, order: order} = context
      product_id_list = Enum.map(products, fn p -> p.id end)

      rule =
        insert(:product_rule,
          preferences: %{match_policy: "all", product_list: product_id_list}
        )

      rule = Repo.get(PromotionRule, rule.id)

      assert true ==
               Enum.all?(order.line_items, fn line_item ->
                 ProductRule.line_item_actionable?(line_item, rule) == true
               end)
    end

    test "returns false for match policy 'all' if id not found ", context do
      %{order: order} = context
      product = insert(:product)

      rule =
        insert(:product_rule,
          preferences: %{match_policy: "all", product_list: [product.id]}
        )

      rule = Repo.get(PromotionRule, rule.id)

      assert false ==
               Enum.all?(order.line_items, fn line_item ->
                 ProductRule.line_item_actionable?(line_item, rule) == true
               end)
    end

    test "returns false for match policy none", context do
      %{products: products, order: order} = context
      product_id_list = Enum.map(products, fn p -> p.id end)

      rule =
        insert(:product_rule,
          preferences: %{match_policy: "none", product_list: product_id_list}
        )

      rule = Repo.get(PromotionRule, rule.id)

      assert false ==
               Enum.all?(order.line_items, fn line_item ->
                 ProductRule.line_item_actionable?(line_item, rule) == true
               end)
    end
  end
end
