defmodule Snitch.Data.Schema.PromotionRule.ProductTest do
  @moduledoc false

  use ExUnit.Case
  use Snitch.DataCase
  import Snitch.Factory
  alias Snitch.Data.Schema.PromotionRule.Product, as: ProductRule

  @success_message "product rule applies for order"
  @failure_messsage "product rule fails for the order"

  setup do
    products = insert_list(3, :product, %{promotionable: false})
    order = insert(:order, state: :delivery)

    _set_line_items =
      line_items(%{order: order, variants: products, line_item_count: length(products)})

    [order: order, products: products]
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
end
