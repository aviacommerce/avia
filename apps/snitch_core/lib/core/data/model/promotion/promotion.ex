defmodule Snitch.Data.Model.Promotion do
  @moduledoc """
  APIs for promotion.
  """
  use Snitch.Data.Model
  alias Snitch.Data.Model.Promotion.{Applicability, Eligibility}
  alias Snitch.Data.Model.PromotionAdjustment
  alias Snitch.Data.Schema.Promotion

  @doc """
  Applies a coupon to the supplied order depending on some
  conditions.

  Returns {:ok, map} | {:error, map} depending on whether the coupon was
  applied or not.

  ### Note
  At present adjustments can happen for only one valid coupon at a time, multiple
  coupon application is not supported.
  """
  @spec apply(order :: Order.t(), coupon :: String.t()) ::
          {:ok, map}
          | {:error, map}
  def apply(order, coupon) do
    with {:ok, promotion} <- Applicability.valid_coupon_check(coupon),
         {:ok, _message} <- Eligibility.eligible(order, promotion) do
      if activate?(order, promotion) do
        process_adjustments(order, promotion)
      end
    else
      {:error, _message} = reason ->
        reason
    end
  end

  @doc """
  Applies actions for a promotion on an order.

  Returns true if promotion actions are applied otherwise, returns false.
  """
  def activate?(order, promotion) do
    promotion = Repo.preload(promotion, :actions)

    promotion.actions
    |> Enum.map(fn action ->
      action.module.perform?(order, promotion, action)
    end)
    |> Enum.any?(fn item -> item == true end)
  end

  @doc """
  Returns a list of ids of `products` which can be activated by `promotion actions`
  related to `line_items`.

  In case no rules are set `true` is returned for the supplied `line_item`.
  """
  @spec line_item_actionable?(line_item :: LineItem.t(), Promotion.t()) :: boolean()
  def line_item_actionable?(line_item, %Promotion{match_policy: "all"} = promotion) do
    promotion = Repo.preload(promotion, :rules)

    Enum.all?(promotion.rules, fn rule ->
      rule.module.line_item_actionable?(line_item, rule)
    end)
  end

  def line_item_actionable?(line_item, %Promotion{match_policy: "any"} = promotion) do
    promotion = Repo.preload(promotion, :rules)

    if promotion.rules == [] do
      true
    else
      Enum.any?(promotion.rules, fn rule ->
        rule.module.line_item_actionable?(line_item, rule)
      end)
    end
  end

  ############################## private functions ####################

  defp process_adjustments(order, promotion) do
    %{
      current_discount: current_discount,
      previous_discount: previous_discount,
      previous_eligible_adjustment_ids: prev_eligible_ids,
      current_adjustment_ids: current_adjustment_ids
    } = get_discount_amounts(order, promotion)

    if current_discount > previous_discount do
      case PromotionAdjustment.activate_adjustments(
             prev_eligible_ids,
             current_adjustment_ids
           ) do
        {:ok, _data} ->
          {:ok, "promotion applied"}

        {:error, _data} ->
          {:error, "promotion activation failed"}
      end
    else
      {:error, "better promotion already exists"}
    end
  end

  defp get_discount_amounts(order, promotion) do
    current_adjustments = PromotionAdjustment.order_adjustments_for_promotion(order, promotion)

    current_discount =
      Enum.reduce(current_adjustments, 0, fn adjustment, acc ->
        -1 * adjustment.amount + acc
      end)

    previous_eligible_adjustments = PromotionAdjustment.eligible_order_adjustments(order)

    previous_discount =
      Enum.reduce(previous_eligible_adjustments, 0, fn adjustment, acc ->
        -1 * adjustment.amount + acc
      end)

    %{
      current_discount: current_discount,
      previous_discount: previous_discount,
      previous_eligible_adjustment_ids: get_adjustment_ids(previous_eligible_adjustments),
      current_adjustment_ids: get_adjustment_ids(current_adjustments)
    }
  end

  defp get_adjustment_ids(adjustments) do
    Enum.map(adjustments, fn adjustment ->
      adjustment.id
    end)
  end
end
