defmodule Snitch.Data.Model.Promotion.Eligbility do
  @moduledoc """
  This module defines functions to check eligiblity of payload
  for a promotion.
  """

  alias Snitch.Data.Schema.{Order, Promotion}

  @error_message %{
    expired_coupon: "coupon expired",
    usage_limit: "coupon usage limit reached",
    invalid_promotion: "promotion is invalid"
  }

  @success_message "applicable"

  @doc """
  Checks if the supplied order payload is eligible for the
  supplied promotion.

  > Note
  The order should be in the "delivery" state.

  First runs promotion level checks to verify if it is applicable
  then runs a check on the rules of the promotion on the basis
  of match_policy.
  A match policy of type "all" checks that all the rules should
  be satisfied to apply the promotion.
  A match policy of type "any" checks that any one of the rules
  should be satisfied to apply the promotions.
  """
  @spec eligible(Order.t(), Promotion.t()) ::
          {true, String.t()}
          | {false, String.t()}
  def eligible(%{state: "delivery"} = order, promotion) do
    match_policy = promotion.match_policy

    with {true, _} <- promotion_level_check(promotion),
         {true, _} <- check_eligibility(match_policy, order, promotion) do
      {true, @success_message}
    else
      {false, _} = error ->
        error
    end
  end

  defp check_eligibility(_, order, %{rules: []}) do
    {true, @success_message}
  end

  defp check_eligibility("all", order, promotion) do
    rules = promotion.rules

    Enum.reduce_while(rules, {true, @success_message}, fn rule, acc ->
      case rule_eligibility(order, rule) do
        {true, _} ->
          {:cont, acc}

        {false, _reason} = error ->
          acc = error
          {:halt, acc}
      end
    end)
  end

  defp check_eligibility("any", order, promotion) do
    rules = promotion.rules

    Enum.reduce_while(rules, {false, @error_message.invalid_promotion}, fn rule, _ ->
      case rule_eligibility(order, rule) do
        {false, _reason} = reason ->
          acc = reason
          {:cont, acc}

        {true, _reason} = reason ->
          acc = reason
          {:halt, acc}
      end
    end)
  end

  defp rule_eligibility(order, rule) do
    module = String.to_existing_atom(rule.module)
    module.eligible(order, rule.preferences)
  end

  defp promotion_level_check(promotion) do
    with true <- promotion.active,
         {true, _} <- expires_at_check(promotion.expires_at),
         {true, _} <-
           current_usage_check(
             promotion.current_usage_count,
             promotion.usage_limit
           ) do
      {true, @success_message}
    else
      false ->
        {false, @error_message.invalid_promotion}

      {false, _} = error ->
        error
    end
  end

  defp expires_at_check(date) do
    case DateTime.compare(DateTime.utc_now(), date) do
      :lt ->
        {true, @success_message}

      :gt ->
        {false, @error_message.expired_coupon}
    end
  end

  defp current_usage_check(current_usage, usage_limit) do
    if usage_limit == 0 do
      {true, @success_message}
    else
      if current_usage < usage_limit do
        {true, @success_message}
      else
        {false, @error_message.usage_limit}
      end
    end
  end
end
