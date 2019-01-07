defmodule Snitch.Data.Schema.PromotionAdjustment do
  @moduledoc """
  Models `order promotion adjustments`.

  Assists in keeping a track of adjustments made due to a
  `promotion action`.
  """

  use Snitch.Data.Schema
  @type t :: %__MODULE__{}

  alias Snitch.Data.Schema.{Order, Promotion, PromotionAction, PromotionAdjustment}

  schema "snitch_promotion_adjustments" do
    belongs_to(:order, Order)
    belongs_to(:promotion, Promotion)
    belongs_to(:promotion_action, PromotionAction)
    belongs_to(:adjustment, PromotionAdjustment)

    timestamps()
  end

  @all_params ~w(order_id promotion_id promotion_action_id adjustment_id)a

  def create_changeset(%__MODULE__{} = promo_adjustment, params) do
    promo_adjustment
    |> cast(params, @all_params)
    |> validate_required(@all_params)
    |> foreign_key_constraint(:order_id)
    |> foreign_key_constraint(:promotion_id)
    |> foreign_key_constraint(:promotion_action_id)
    |> foreign_key_constraint(:adjustment_id)
  end
end
