defmodule Snitch.Data.Schema.PromotionAction.OrderActionTest do
  @moduledoc false

  use ExUnit.Case
  use Snitch.DataCase
  import Snitch.Factory
  alias Snitch.Data.Schema.PromotionAction.OrderAction

  describe "perform?/2" do
    setup do
      order = insert(:order)
      promotion = insert(:promotion)
      order_action = insert(:promotion_order_action, promotion: promotion)
      [promotion: promotion, action: order_action, order: order]
    end

    test "returns true for order action set", context do
      %{promotion: promotion, order: order} = context
      promotion = Repo.preload(promotion, :actions)
      [action] = promotion.actions

      assert true == OrderAction.perform?(order, promotion, action)
    end

    test "returns false in case of any error ", context do
      %{promotion: promotion, order: order} = context
      promotion = Repo.preload(promotion, :actions)
      [action] = promotion.actions

      ## modifying promotion id to non-existent one.
      promotion = Map.put(promotion, :id, -1)

      assert false == OrderAction.perform?(order, promotion, action)
    end
  end
end
