defmodule Snitch.Data.Model.Promotion.Elibility do
  @moduledoc """
  Module exposes fucntions to handle elgibility related functionality
  for a `promotion`.

  A `promotion` is applicable based on a set of conditions such as:
  - valid coupon code
  - is not expired
  - usage count

  Also the payload mainly an order should also satisfy some basic checks
  along with `promotion rules` to be eligible for the promotion.
  """

  @doc """
  Checks for the validity of the supplied `promotion` and eligibiltiy of
  the supplied order.

  The function first runs a promotion level checks to verify if it is applicable.
  It then checks for if the supplied order meets the required conditions to be
  applicable for a promotion. It then runs a check on the rules of the promotion
  on the basis of `match_policy` to give the final result.

  """
  @spec eligible(order :: Order.t(), coupon :: String.t()) ::
          {true, String.t()}
          | {false, String.t()}
  def eligible(%{state: "delivery"} = order, promotion) do
  end

  ############## permission level checks ###############
  def promotion_level_check(promotion) do
  end

  defp valid_coupon_check(coupon) do
  end

  defp promotion_active?() do
  end

  defp promotion_action_exists?(promotion) do
  end

  defp expires_at_check(date) do
  end

  defp current_usage_check(current_usage, usage_limit) do
  end

  ############## order level checks ###############

  def order_level_check(order, promotion) do
  end

  defp promotion_applied?(order, promotion) do
  end

  defp valid_order_state(order) do
  end

  defp order_promotionable(order) do
  end

  defp rule_eligibility(order, promotion) do
  end
end
