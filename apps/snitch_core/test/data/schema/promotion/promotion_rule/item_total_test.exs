defmodule Snitch.Data.Schema.PromotionRule.ItemTotalTest do
  @moduledoc false

  use ExUnit.Case, async: true
  use Snitch.DataCase
  import Snitch.Factory
  alias Snitch.Data.Schema.PromotionRule.ItemTotal

  describe "eligible/2" do
    setup do
      order = insert(:order, state: :address)

      _line_item =
        insert(:line_item, order: order, quantity: 2, unit_price: Money.new("9.99", currency()))

      [order: order]
    end

    test "order statisfies the rule if upper limit set", context do
      %{order: order} = context

      promotion_rule =
        insert(:item_total_rule,
          preferences: %{lower_range: 10, upper_range: 100}
        )

      promotion = Repo.preload(promotion_rule.promotion, :rules)
      [promotion_rule] = promotion.rules

      assert {true, message} = ItemTotal.eligible(order, promotion_rule.preferences)
    end

    test "order statisfies the rule if upper limit not set", context do
      %{order: order} = context

      promotion_rule =
        insert(:item_total_rule,
          preferences: %{lower_range: 10, upper_range: 0.0}
        )

      promotion = Repo.preload(promotion_rule.promotion, :rules)
      [promotion_rule] = promotion.rules

      assert {true, message} = ItemTotal.eligible(order, promotion_rule.preferences)
    end

    test "order does not statisfy rule less than lower_range", context do
      %{order: order} = context

      promotion_rule =
        insert(:item_total_rule,
          preferences: %{lower_range: 30, upper_range: 0.0}
        )

      promotion = Repo.preload(promotion_rule.promotion, :rules)
      [promotion_rule] = promotion.rules

      assert {false, message} = ItemTotal.eligible(order, promotion_rule.preferences)
      assert message == "order doesn't falls under the item total condition"
    end
  end
end
