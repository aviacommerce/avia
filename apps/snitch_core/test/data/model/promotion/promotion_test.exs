defmodule Snitch.Data.Model.PromotionTest do
  @moduledoc false

  use ExUnit.Case
  use Snitch.DataCase
  import Snitch.Factory
  alias Snitch.Data.Model.Promotion

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
end
