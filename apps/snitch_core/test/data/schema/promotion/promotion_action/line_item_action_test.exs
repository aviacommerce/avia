defmodule Snitch.Data.Schema.PromotionAction.LineItemActionTest do
  @moduledoc false

  use ExUnit.Case
  use Snitch.DataCase
  import Snitch.Factory
  alias Snitch.Data.Schema.PromotionAction.LineItemAction

  describe "perform?/2" do
    setup do
      products = insert_list(3, :product, %{promotionable: true})
      order = insert(:order, state: :delivery)

      ## setup line_items
      line_items(%{order: order, variants: products, line_item_count: length(products)})

      promotion = insert(:promotion)
      action = insert(:promotion_line_item_action, promotion: promotion)

      [promotion: promotion, action: action, order: order, products: products]
    end

    test "returns true as adjustments are created", context do
      %{order: order, promotion: promotion} = context
      promotion = Repo.preload(promotion, [:actions, :rules])
      [action] = promotion.actions

      assert true == LineItemAction.perform?(order, promotion, action)
    end

    test "returns false as no actionable items found", context do
      %{order: order, products: products, promotion: promotion} = context
      product_list = Enum.map(products, fn p -> p.id end)

      insert(:product_rule,
        promotion: promotion,
        preferences: %{match_policy: "none", product_list: product_list}
      )

      promotion = Repo.preload(promotion, :actions)
      [action] = promotion.actions

      assert false == LineItemAction.perform?(order, promotion, action)
    end
  end
end
