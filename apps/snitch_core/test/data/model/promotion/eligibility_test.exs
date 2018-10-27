defmodule Snitch.Data.Model.Promotion.EligibilityTest do
  use ExUnit.Case
  use Snitch.DataCase

  import Snitch.Factory

  alias Snitch.Data.Model.Promotion.Eligbility
  alias Snitch.Data.Schema.PromotionRule

  describe "eligible?/2" do
    setup :zones
    setup :shipping_methods
    setup :embedded_shipping_methods
    setup :order_in_delivery_state

    test "returns false for expired promotion", context do
      %{order: order} = context

      promotion =
        insert(:promotion,
          expires_at: Timex.shift(DateTime.utc_now(), years: -1)
        )

      {false, message} = Eligbility.eligible(order, promotion)
      assert message == "coupon expired"
    end

    # Total usage
    test "returns false for usage_count exceeded", context do
      %{order: order} = context

      promotion =
        insert(:promotion,
          current_usage_count: 10
        )

      {false, message} = Eligbility.eligible(order, promotion)
      assert message == "coupon usage limit reached"
    end

    # Per user usage
    test "returns false for per user usage_count exceeded", context do
      %{products: products} = context
      promotion = promotion_with_rules(products)
    end

    test "returns false for inactive promotion", context do
      %{order: order} = context
      promotion = insert(:promotion, active: false)

      {false, message} = Eligbility.eligible(order, promotion)
      assert message == "promotion is invalid"
    end

    # OR
    test "returns false, policy 'any'" do
    end

    # OR
    test "returns true, policy 'any'" do
    end

    # AND
    test "returns false, policy 'all'", context do
      %{order: order, products: products} = context
      promotion = promotion_with_rules(products, "all")
      result = Eligbility.eligible(order, promotion)
      require IEx
      IEx.pry()
    end

    # AND
    test "returns true, policy 'all'" do
    end

    #
    test "returns true, if no rules set" do
    end
  end

  defp promotion_with_rules(products, policy) do
    product_rule = product_rule(products)
    order_total_rule = order_total_rule()

    promotion =
      insert(:promotion,
        rule: [product_rule, order_total_rule],
        match_policy: policy
      )
  end

  defp product_rule(products) do
    [product_1, product2] = products

    %PromotionRule{
      module: Snitch.Data.Schema.PromotionRule.Product,
      name: "products",
      preferences: %{
        product_list: [product1.id, product2.id]
      }
    }
  end

  defp order_total_rule() do
    %PromotionRule{
      module: Snitch.Data.Schema.PromotionRule.OrderTotal,
      name: "order total",
      preferences: %{
        lower_range: 10,
        uppper_range: 100
      }
    }
  end

  defp order_in_delivery_state(context) do
    %{embedded_shipping_methods: embedded_shipping_methods} = context

    # setup stock for product
    stock_item_1 = insert(:stock_item, count_on_hand: 5)
    stock_item_2 = insert(:stock_item, count_on_hand: 5)

    # setup product
    product_1 = stock_item_1.product
    product_2 = stock_item_2.product

    # setup shipping category, identifier, rules
    shipping_identifier = insert(:shipping_identifier)

    shipping_category = insert(:shipping_category)

    shipping_rule =
      insert(:shipping_rule,
        lower_limit: 100,
        active?: true,
        shipping_cost: Money.new!(:USD, 100),
        shipping_rule_identifier: shipping_identifier,
        shipping_category: shipping_category
      )

    # make order and it's packages
    order = insert(:order, state: "delivery")
    line_item_1 = insert(:line_item, order: order, product: product_1, quantity: 2)
    line_item_2 = insert(:line_item, order: order, product: product_2, quantity: 2)

    package =
      insert(:package,
        shipping_methods: embedded_shipping_methods,
        order: order,
        items: [],
        origin: stock_item_1.stock_location,
        shipping_category: shipping_category
      )

    package_item_1 =
      insert(:package_item,
        quantity: 2,
        product: product_1,
        line_item: line_item_1,
        package: package
      )

    package_item_2 =
      insert(:package_item,
        quantity: 2,
        product: product_2,
        line_item: line_item_2,
        package: package
      )

    [order: order, products: [product_1, product_2]]
  end
end
