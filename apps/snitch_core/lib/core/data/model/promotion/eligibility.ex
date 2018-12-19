defmodule Snitch.Data.Model.Promotion.Eligibility do
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
  alias Snitch.Data.Model.Promotion.Applicability

  @success_message "coupon eligible"

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
  def eligible(order, coupon) do
    with {:ok, promotion} <- Applicability.valid_coupon_check(coupon),
         true <- promotion_level_check(promotion),
         true <- order_level_check(order, promotion) do
      {:ok, @success_message}
    else
      {:error, _message} = reason ->
        reason

      {false, message} ->
        {:error, message}
    end
  end

  ############## permission level checks ###############
  def promotion_level_check(promotion) do
    with true <- Applicability.promotion_active?(promotion),
         true <- Applicability.promotion_action_exists?(promotion),
         true <- Applicability.starts_at_check(promotion),
         true <- Applicability.expires_at_check(promotion),
         true <- Applicability.usage_limit_check(promotion) do
      true
    else
      {false, _message} = reason ->
        reason
    end
  end

  ############## order level checks ###############

  def order_level_check(order, promotion) do
  end
end
