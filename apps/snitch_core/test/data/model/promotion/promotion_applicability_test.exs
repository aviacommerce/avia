defmodule Snitch.Data.Model.Promotion.ApplicabilityTest do
  @moduledoc false

  use ExUnit.Case, async: true
  use Snitch.DataCase

  alias Snitch.Data.Model.Promotion.Applicability
  alias Snitch.Data.Schema.Promotion

  import Snitch.Factory

  @errors %{
    not_found: "promotion not found",
    inactive: "promotion is not active",
    expired: "promotion has expired"
  }

  describe "valid_coupon_check/1" do
    test "returns error if code not found" do
      promotion = insert(:promotion)
      test_code = "XYZ10"

      assert promotion.code != test_code

      assert {:error, message} = Applicability.valid_coupon_check(test_code)
      assert message = "promotion not found"
    end

    test "returns promotion if code found" do
      promotion = insert(:promotion)

      assert {:ok, %Promotion{} = promo} = Applicability.valid_coupon_check(promotion.code)
    end
  end

  describe "promotion_active?/1" do
    test "returns false if promotion inactive" do
      promotion = insert(:promotion, active?: false)

      assert {false, message} = Applicability.promotion_active?(promotion)
      assert message == "promotion is not active"
    end
  end

  describe "promotion_action_exists?/1" do
    test "returns false if promotion does not have any actions" do
      promotion = insert(:promotion)

      assert {false, message} = Applicability.promotion_action_exists?(promotion)
      assert message == "promotion is not active"
    end

    test "returns true if promo action exists" do
      action = insert(:promotion_order_action)
      assert true = Applicability.promotion_action_exists?(action.promotion)
    end
  end

  describe "starts_at_check/1" do
    test "returns true if starts_at is in past" do
      promotion =
        insert(:promotion,
          starts_at: Timex.shift(DateTime.utc_now(), days: -2)
        )

      assert true = Applicability.starts_at_check(promotion)
    end

    test "returns false if starts_at is in future" do
      promotion =
        insert(:promotion,
          starts_at: Timex.shift(DateTime.utc_now(), days: 2)
        )

      assert {false, message} = Applicability.starts_at_check(promotion)
      assert message == @errors.inactive
    end
  end

  describe "expires_at_check/1" do
    test "returns false if expires_at is in past" do
      promotion =
        insert(:promotion,
          expires_at: Timex.shift(DateTime.utc_now(), days: -1)
        )

      assert true = Applicability.starts_at_check(promotion)
    end

    test "returns true if expires_at is in future" do
      promotion =
        insert(:promotion,
          starts_at: Timex.shift(DateTime.utc_now(), days: -2),
          expires_at: Timex.shift(DateTime.utc_now(), days: 4)
        )

      assert true = Applicability.starts_at_check(promotion)
    end
  end

  describe "current_usage_check/1" do
    test "returns false if current usage over" do
      promotion = insert(:promotion, usage_limit: 10, current_usage_count: 10)

      assert {false, message} = Applicability.usage_limit_check(promotion)
      assert message == @errors.expired
    end
  end
end
