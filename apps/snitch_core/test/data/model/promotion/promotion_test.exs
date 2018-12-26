defmodule Snitch.Data.Model.PromotionTest do
  @moduledoc false

  use ExUnit.Case
  use Snitch.DataCase
  import Snitch.Factory
  alias Snitch.Data.Model.Promotion
  alias Snitch.Data.Model.PromotionAdjustment

  @messages %{
    coupon_applied: "promotion applied",
    better_coupon_exists: "better promotion already exists",
    failed: "promotion activation failed"
  }
  @coupon_applied "coupon already applied"

  describe "line_item_actionable?/2" do
    setup do
      products = insert_list(3, :product, %{promotionable: true})
      order = insert(:order, state: :delivery)

      [line_items: line_items] =
        line_items(%{order: order, variants: products, line_item_count: length(products)})

      cost =
        Enum.reduce(line_items, Money.new!(currency(), 0), fn item, acc ->
          sum = Money.mult!(item.unit_price, item.quantity)
          Money.add!(acc, sum)
        end)

      order = Repo.preload(order, line_items: :product)

      [order: order, products: products, cost: cost]
    end

    test "returns true for match policy 'all'", context do
      %{order: order, products: products, cost: cost} = context
      promotion = insert(:promotion, match_policy: "all")

      insert(:item_total_rule,
        promotion: promotion,
        preferences: %{lower_range: cost.amount, upper_range: 0.0}
      )

      product_id_list = Enum.map(products, fn p -> p.id end)

      insert(:product_rule,
        promotion: promotion,
        preferences: %{match_policy: "all", product_list: product_id_list}
      )

      assert true ==
               Enum.all?(order.line_items, fn line_item ->
                 Promotion.line_item_actionable?(line_item, promotion) == true
               end)
    end

    test "returns true for match policy 'all' if no rules set", context do
      %{order: order} = context
      promotion = insert(:promotion, match_policy: "all")

      assert true ==
               Enum.all?(order.line_items, fn line_item ->
                 Promotion.line_item_actionable?(line_item, promotion) == true
               end)
    end

    test "returns false no actionable items found", context do
      %{order: order, products: products, cost: cost} = context
      promotion = insert(:promotion, match_policy: "all")

      insert(:item_total_rule,
        promotion: promotion,
        preferences: %{lower_range: cost.amount, upper_range: 0.0}
      )

      product_id_list = Enum.map(products, fn p -> p.id end)

      insert(:product_rule,
        promotion: promotion,
        preferences: %{match_policy: "none", product_list: product_id_list}
      )

      assert false ==
               Enum.all?(order.line_items, fn line_item ->
                 Promotion.line_item_actionable?(line_item, promotion) == true
               end)
    end

    test "returns true for match policy 'any'", context do
      %{order: order, products: products, cost: cost} = context
      promotion = insert(:promotion, match_policy: "any")

      insert(:item_total_rule,
        promotion: promotion,
        preferences: %{lower_range: cost.amount, upper_range: 0.0}
      )

      product_id_list = Enum.map(products, fn p -> p.id end)

      insert(:product_rule,
        promotion: promotion,
        preferences: %{match_policy: "none", product_list: product_id_list}
      )

      assert true ==
               Enum.all?(order.line_items, fn line_item ->
                 Promotion.line_item_actionable?(line_item, promotion) == true
               end)
    end

    test "returns true for match policy 'any' if no rules set", context do
      %{order: order} = context
      promotion = insert(:promotion, match_policy: "any")

      assert true ==
               Enum.all?(order.line_items, fn line_item ->
                 Promotion.line_item_actionable?(line_item, promotion) == true
               end)
    end
  end

  describe "apply/2" do
    test "applies promotion code" do
      item_info = %{quantity: 2, unit_price: Money.new!(currency(), 10)}
      action_manifest = %{order_action: Decimal.new(10), line_item_action: Decimal.new(10)}

      %{order: order, order_total: order_total, product_ids: product_ids} = setup_order(item_info)
      item_total_cost = Decimal.sub(order_total.amount, 1)

      rule_manifest = %{item_total_cost: item_total_cost, product_ids: product_ids}

      promotion = insert(:promotion)
      set_rules_and_actions(promotion, rule_manifest, action_manifest)

      {:ok, message} = Promotion.apply(order, promotion.code)
      assert message == "promotion applied"

      adjustments = PromotionAdjustment.order_adjustments_for_promotion(order, promotion)

      Enum.each(adjustments, fn adjustment ->
        assert adjustment.eligible == true
      end)
    end

    test "successfully reapply another promotion for order" do
      item_info = %{quantity: 2, unit_price: Money.new!(currency(), 10)}

      %{order: order, order_total: order_total, product_ids: product_ids} =
        order_params = setup_order(item_info)

      item_total_cost = Decimal.sub(order_total.amount, 1)

      rule_manifest = %{item_total_cost: item_total_cost, product_ids: product_ids}
      action_manifest = %{order_action: Decimal.new(15), line_item_action: Decimal.new(15)}

      %{promotion: promotion} = apply_promotion(order_params)

      adjustments = PromotionAdjustment.order_adjustments_for_promotion(order, promotion)

      ## shows previous promotion adjustments are activated
      Enum.each(adjustments, fn adjustment ->
        assert adjustment.eligible == true
      end)

      promotion_other = insert(:promotion, code: "50OFF")
      set_rules_and_actions(promotion_other, rule_manifest, action_manifest)

      {:ok, message} = Promotion.apply(order, promotion_other.code)
      assert message == @messages.coupon_applied

      old_adjustments = PromotionAdjustment.order_adjustments_for_promotion(order, promotion)

      new_adjustments =
        PromotionAdjustment.order_adjustments_for_promotion(order, promotion_other)

      Enum.each(old_adjustments, fn adjustment ->
        assert adjustment.eligible == false
      end)

      Enum.each(new_adjustments, fn adjustment ->
        assert adjustment.eligible == true
      end)
    end

    test "does not apply another promotion for order as better one exists" do
      item_info = %{quantity: 2, unit_price: Money.new!(currency(), 10)}

      %{order: order, order_total: order_total, product_ids: product_ids} =
        order_params = setup_order(item_info)

      item_total_cost = Decimal.sub(order_total.amount, 1)

      rule_manifest = %{item_total_cost: item_total_cost, product_ids: product_ids}
      action_manifest = %{order_action: Decimal.new(5), line_item_action: Decimal.new(5)}

      %{promotion: promotion} = apply_promotion(order_params)

      adjustments = PromotionAdjustment.order_adjustments_for_promotion(order, promotion)

      ## shows previous promotion adjustments are activated
      Enum.each(adjustments, fn adjustment ->
        assert adjustment.eligible == true
      end)

      promotion_other = insert(:promotion, code: "50OFF")
      set_rules_and_actions(promotion_other, rule_manifest, action_manifest)

      {:error, message} = Promotion.apply(order, promotion_other.code)
      assert message == @messages.better_coupon_exists

      old_adjustments = PromotionAdjustment.order_adjustments_for_promotion(order, promotion)

      new_adjustments =
        PromotionAdjustment.order_adjustments_for_promotion(order, promotion_other)

      Enum.each(old_adjustments, fn adjustment ->
        assert adjustment.eligible == true
      end)

      Enum.each(new_adjustments, fn adjustment ->
        assert adjustment.eligible == false
      end)
    end

    test "fails if the same coupon is applied again" do
      item_info = %{quantity: 2, unit_price: Money.new!(currency(), 10)}
      %{order: order} = order_params = setup_order(item_info)

      %{promotion: promotion} = apply_promotion(order_params)

      {:error, message} = Promotion.apply(order, promotion.code)
      assert message == @coupon_applied
    end

    test "fails if some rule does not applies" do
      item_info = %{quantity: 2, unit_price: Money.new!(currency(), 10)}
      %{order: order, order_total: order_total} = setup_order(item_info)

      ## set new products not present in the order
      products = insert_list(2, :product, promotionable: true)
      product_ids = Enum.map(products, fn p -> p.id end)
      item_total_cost = Decimal.sub(order_total.amount, 1)

      action_manifest = %{order_action: Decimal.new(10), line_item_action: Decimal.new(10)}
      rule_manifest = %{item_total_cost: item_total_cost, product_ids: product_ids}

      promotion = insert(:promotion)
      set_rules_and_actions(promotion, rule_manifest, action_manifest)

      {:error, message} = Promotion.apply(order, promotion.code)
      assert message == "product rule fails for the order"
    end

    test "fails as coupon code not found" do
      item_info = %{quantity: 2, unit_price: Money.new!(currency(), 10)}
      %{order: order} = setup_order(item_info)

      {:error, message} = Promotion.apply(order, "XYZ")
      assert message == "promotion not found"
    end
  end

  defp apply_promotion(order_params) do
    action_manifest = %{order_action: Decimal.new(10), line_item_action: Decimal.new(10)}
    %{order: order, order_total: order_total, product_ids: product_ids} = order_params

    item_total_cost = Decimal.sub(order_total.amount, 1)

    rule_manifest = %{item_total_cost: item_total_cost, product_ids: product_ids}

    promotion = insert(:promotion)
    set_rules_and_actions(promotion, rule_manifest, action_manifest)

    {:ok, _message} = Promotion.apply(order, promotion.code)

    %{promotion: promotion}
  end

  defp set_rules_and_actions(promotion, rule_manifest, action_manifest) do
    %{item_total_cost: cost, product_ids: product_ids} = rule_manifest
    %{order_action: order_action_data, line_item_action: line_item_action_data} = action_manifest

    insert(:item_total_rule,
      promotion: promotion,
      preferences: %{lower_range: cost, upper_range: Decimal.new(0)}
    )

    insert(:product_rule,
      promotion: promotion,
      preferences: %{match_policy: "all", product_list: product_ids}
    )

    insert(:promotion_order_action,
      preferences: %{
        calculator_module: "Elixir.Snitch.Domain.Calculator.FlatRate",
        calculator_preferences: %{amount: order_action_data}
      },
      promotion: promotion
    )

    insert(:promotion_line_item_action,
      preferences: %{
        calculator_module: "Elixir.Snitch.Domain.Calculator.FlatRate",
        calculator_preferences: %{amount: line_item_action_data}
      },
      promotion: promotion
    )
  end

  defp setup_order(item_info) do
    %{quantity: quantity, unit_price: unit_price} = item_info

    products = insert_list(3, :product, promotionable: true)

    order = insert(:order, state: "delivery")

    line_items =
      Enum.map(products, fn product ->
        insert(:line_item,
          order: order,
          product: product,
          quantity: quantity,
          unit_price: unit_price
        )
      end)

    cost =
      Enum.reduce(line_items, Money.new!(currency(), 0), fn item, acc ->
        sum = Money.mult!(item.unit_price, item.quantity)
        Money.add!(acc, sum)
      end)

    product_ids = Enum.map(products, fn product -> product.id end)

    %{
      order: order,
      line_items: line_items,
      products: products,
      product_ids: product_ids,
      order_total: cost
    }
  end
end
