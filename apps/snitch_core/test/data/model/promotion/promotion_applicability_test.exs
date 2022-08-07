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

  @success %{
    promo_active: "promotion active",
    has_actions: "has actions"
  }

  describe "valid_coupon_check/1" do
    test "returns error if code not found" do
      promotion = insert(:promotion)
      test_code = "XYZ10"

      assert promotion.code != test_code

      assert {:error, message} = Applicability.valid_coupon_check(test_code)
      assert message = "promotion not found"
    end

    test "returns error if promotion archived" do
      current_unix_time = DateTime.utc_now() |> DateTime.to_unix()
      promotion = insert(:promotion)

      # does not return error if promotion not archived
      assert {:ok, %Promotion{} = promo} = Applicability.valid_coupon_check(promotion.code)

      cs = Promotion.update_changeset(promotion, %{archived_at: current_unix_time})
      {:ok, promotion} = Repo.update(cs)

      # returns error as promotion archived now
      assert {:error, message} = Applicability.valid_coupon_check(promotion.code)
      assert message = "promotion not found"
    end
  end

  describe "promotion_active/1" do
    test "returns false if promotion inactive" do
      promotion = insert(:promotion, active?: false)

      assert {false, message} = Applicability.promotion_active(promotion)
      assert message == "promotion is not active"
    end
  end

  describe "promotion_action_exists?/1" do
    test "returns false if promotion does not have any actions" do
      promotion = insert(:promotion)

      assert {false, message} = Applicability.promotion_actions_exist(promotion)
      assert message == "promotion is not active"
    end

    test "returns true if promo action exists" do
      action = insert(:promotion_order_action)
      assert {true, message} = Applicability.promotion_actions_exist(action.promotion)
      assert message == @success.has_actions
    end
  end

  describe "starts_at_check/1" do
    test "returns true if starts_at is in past" do
      promotion =
        insert(:promotion,
          starts_at: Timex.shift(DateTime.utc_now(), days: -2)
        )

      assert {true, message} = Applicability.starts_at_check(promotion)
      assert message == @success.promo_active
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

      assert {false, message} = Applicability.expires_at_check(promotion)
      assert message == @errors.expired
    end

    test "returns true if expires_at is in future" do
      promotion =
        insert(:promotion,
          starts_at: Timex.shift(DateTime.utc_now(), days: -2),
          expires_at: Timex.shift(DateTime.utc_now(), days: 4)
        )

      assert {true, message} = Applicability.expires_at_check(promotion)
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
