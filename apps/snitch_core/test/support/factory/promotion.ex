defmodule Snitch.Factory.Promotion do
  defmacro __using__(_opts) do
    quote do
      alias Snitch.Data.Schema.Promotion

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
    end
  end
end
