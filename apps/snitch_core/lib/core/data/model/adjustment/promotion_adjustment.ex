defmodule Snitch.Data.Model.PromotionAdjustment do
  @moduledoc """
  Exposes functions related to adjustments created for
  promotions.
  """

  use Snitch.Data.Model
  alias Ecto.Multi
  alias Snitch.Data.Model.Adjustment
  alias Snitch.Data.Schema.PromotionAdjustment
  alias Snitch.Data.Schema.Adjustment, as: AdjustmentSchema

  @doc """
  Creates a promotion adjustment.

  The function creates an `adjustment` record alongwith the `promotion adjustment`.
  ### See
  `Snitch.Data.Schema.Adjustment`

  The function expects following keys in the `params`
    - `:order`
    - `:promotion`
    - `:promotion_action`
    - `:adjustable_type`
    - `:adjustable_id`
    - `:amount`

  ### Note
    All the above mentioned keys are mandatory for creating an adjustment.
  """
  @spec create(map) :: {:ok, PromotionAdjustment.t()} | {:error, Ecto.Changeset.t()}
  def create(params) do
    Multi.new()
    |> Multi.run(:adjustment, fn _ ->
      params = set_adjustment_params(params)
      Adjustment.create(params)
    end)
    |> Multi.run(:promo_adj, fn %{adjustment: adjustment} ->
      params = set_promo_adjustment_params(params, adjustment)
      QH.create(PromotionAdjustment, params, Repo)
    end)
    |> persist()
  end

  def order_adjustments(order) do
    query =
      from(adj in AdjustmentSchema,
        join: p_adj in PromotionAdjustment,
        on: adj.id == p_adj.adjustment_id,
        where: p_adj.order_id == ^order.id,
        select: %AdjustmentSchema{
          amount: adj.amount,
          eligible: adj.eligible,
          id: adj.id,
          label: adj.label,
          adjustable_type: adj.adjustable_type,
          adjustable_id: adj.adjustable_id
        }
      )

    Repo.all(query)
  end

  def order_adjustments_for_promotion(order, promotion) do
    query =
      from(adj in AdjustmentSchema,
        join: p_adj in PromotionAdjustment,
        on: adj.id == p_adj.adjustment_id,
        where: p_adj.order_id == ^order.id and p_adj.promotion_id == ^promotion.id,
        select: %AdjustmentSchema{
          amount: adj.amount,
          eligible: adj.eligible,
          id: adj.id,
          label: adj.label,
          adjustable_type: adj.adjustable_type,
          adjustable_id: adj.adjustable_id
        }
      )

    Repo.all(query)
  end

  def eligible_order_adjustments(order) do
    query =
      from(adj in AdjustmentSchema,
        join: p_adj in PromotionAdjustment,
        on: adj.id == p_adj.adjustment_id,
        where: p_adj.order_id == ^order.id and adj.eligible == true,
        select: %AdjustmentSchema{
          amount: adj.amount,
          eligible: adj.eligible,
          id: adj.id,
          label: adj.label,
          adjustable_type: adj.adjustable_type,
          adjustable_id: adj.adjustable_id
        }
      )

    Repo.all(query)
  end

  def activate_adjustments(prev_eligible_ids, current_adjustment_ids) do
    Multi.new()
    |> Multi.run(:remove_eligible_adjustments, fn _ ->
      {:ok, update_adjustments(prev_eligible_ids, false)}
    end)
    |> Multi.run(:activate_new_adjustments, fn _ ->
      {:ok, update_adjustments(current_adjustment_ids, true)}
    end)
    |> Repo.transaction()
    |> case do
      {:ok, data} ->
        {:ok, data}

      {:error, _, data, _} ->
        {:error, data}
    end
  end

  ################## private functions ################

  defp update_adjustments(ids, eligible) do
    Repo.update_all(
      from(adj in AdjustmentSchema,
        where: adj.id in ^ids
      ),
      set: [eligible: eligible]
    )
  end

  defp set_promo_adjustment_params(params, adjustment) do
    %{
      order_id: params.order.id,
      promotion_action_id: params.promotion_action.id,
      promotion_id: params.promotion.id,
      adjustment_id: adjustment.id
    }
  end

  defp set_adjustment_params(params) do
    %{
      adjustable_type: params.adjustable_type,
      adjustable_id: params.adjustable_id,
      amount: params.amount,
      label: params.promotion.code <> "(#{params.amount})"
    }
  end

  # Run the accumulated multi struct
  defp persist(multi) do
    case Repo.transaction(multi) do
      {:ok, %{promo_adj: promo_adjustment}} ->
        {:ok, promo_adjustment}

      {:error, _, data, _} ->
        {:error, data}
    end
  end
end
