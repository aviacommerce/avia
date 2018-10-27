defmodule Snitch.Factory.Promotion do
  defmacro __using__(_) do
    quote do
      alias Snitch.Data.Schema.Promotion

      def promotion_factory do
        %Promotion{
          code: sequence(:promo_code, &"PromoCode-#{&1}"),
          description: "",
          starts_at: DateTime.utc_now(),
          expires_at: Timex.shift(DateTime.utc_now(), years: 1),
          usage_limit: 10,
          current_usage_count: 0,
          match_policy: "all",
          active: true,
          rules: []
        }
      end
    end
  end
end
