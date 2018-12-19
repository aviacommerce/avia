defmodule Snitch.Factory.Promotion do
  defmacro __using__(_opts) do
    quote do
      alias Snitch.Data.Schema.{Promotion, PromotionAction}

      def promotion_factory() do
        %Promotion{
          code: "BIGSALE",
          name: "sale 10% off",
          starts_at: DateTime.utc_now(),
          expires_at: Timex.shift(DateTime.utc_now(), days: 30),
          usage_limit: 20,
          current_usage_count: 0,
          match_policy: "all",
          active?: true
        }
      end

      def promotion_order_action_factory() do
        %PromotionAction{
          name: "Order Action",
          module: "Elixir.Snitch.Data.Schema.PromotionAction.OrderAction",
          preferences: %{
            calculator_module: "Elixir.Snitch.Domain.Calculator.FlatRate",
            calculator_preferences: %{amount: 5}
          },
          promotion: build(:promotion)
        }
      end
    end
  end
end
