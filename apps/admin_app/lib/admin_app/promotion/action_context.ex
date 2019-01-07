defmodule AdminApp.Promotion.ActionContext do
  @moduledoc false

  alias AdminApp.Promotion.CalculatorContext

  @order_action Snitch.Data.Schema.PromotionAction.OrderAction
  @line_item_action Snitch.Data.Schema.PromotionAction.LineItemAction
  @promo_calculator_url "/promo-calculators"

  def action_preferences(model, params \\ %{})

  def action_preferences(@order_action, params) do
    prefs(@order_action, params)
  end

  def action_preferences(@line_item_action, params) do
    prefs(@line_item_action, params)
  end

  defp prefs(module, params) when map_size(params) == 0 do
    %{
      name: module,
      action_data: [
        %{key: :calculator_module, value: nil, type: "select", source: @promo_calculator_url},
        %{key: :calculator_preferences, value: nil}
      ]
    }
  end

  defp prefs(module, params) do
    calculator_module = String.to_existing_atom(params["calculator_module"])
    calculator_params = params["calculator_preferences"]

    %{
      name: module,
      action_data: [
        %{
          key: :calculator_module,
          value: params["calculator_module"],
          type: "select",
          source: @promo_calculator_url
        },
        %{
          key: :calculator_preferences,
          value: CalculatorContext.preferences(calculator_module, calculator_params)
        }
      ]
    }
  end
end
