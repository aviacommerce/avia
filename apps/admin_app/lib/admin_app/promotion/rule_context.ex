defmodule AdminApp.Promotion.RuleContext do
  @moduledoc false

  @item_total Snitch.Data.Schema.PromotionRule.OrderTotal
  @product Snitch.Data.Schema.PromotionRule.Product

  def rule_preferences(model, params \\ %{})

  def rule_preferences(@item_total, params) do
    %{
      name: @item_total,
      rule_data: [
        %{key: :lower_range, type: "input", value: params["lower_range"]},
        %{key: :upper_range, type: "input", value: params["upper_range"]}
      ]
    }
  end

  def rule_preferences(@product, params) do
    %{
      name: @product,
      rule_data: [
        %{
          key: :product_list,
          type: "multi-select",
          value: params["product_list"],
          # TODO: Add the right product search API here,
          #       added string is only a placeholder.
          source: "/api/product/search"
        },
        %{
          key: :match_policy,
          type: "select",
          value: params["match_policy"],
          source: ["all", "any", "none"]
        }
      ]
    }
  end
end
