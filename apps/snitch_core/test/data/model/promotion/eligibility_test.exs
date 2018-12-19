defmodule Snitch.Data.Model.Promotion.EligibilityTest do
  @moduledoc false

  use ExUnit.Case, async: true
  use Snitch.DataCase

  import Snitch.Factory

  alias Snitch.Data.Model.Promotion.Eligibility

  describe "promotion_level_check/1" do
    test "returns true if all checks satisfy" do
      promotion =
        insert(:promotion,
          active?: true,
          starts_at: Timex.shift(DateTime.utc_now(), days: -2),
          expires_at: Timex.shift(DateTime.utc_now(), days: 3),
          usage_limit: 5,
          current_usage_count: 2
        )

      action = insert(:promotion_order_action, promotion: promotion)

      assert true == Eligibility.promotion_level_check(promotion)
    end

    test "returns false with error if any check fails" do
      promotion =
        insert(:promotion,
          active?: true,
          starts_at: Timex.shift(DateTime.utc_now(), days: -2),
          expires_at: Timex.shift(DateTime.utc_now(), days: 3),
          usage_limit: 5,
          current_usage_count: 2
        )

      ## fails since we have not set any action for the promotion
      assert {false, message} = Eligibility.promotion_level_check(promotion)
      assert message == "promotion is not active"
    end
  end
end
