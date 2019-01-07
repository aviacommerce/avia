defmodule Snitch.Repo.Migrations.AddAdjustmentsAndPromoAdjustment do
  use Ecto.Migration

  def change do
    create table("snitch_adjustments") do
      add(:adjustable_type, AdjustableEnum.type(), null: false)
      add(:adjustable_id, :integer, null: false)
      add(:amount, :decimal)
      add(:label, :string)
      add(:eligible, :boolean, default: false)
      add(:included, :boolean, default: false)

      timestamps()
    end

    create table("snitch_promotion_adjustments") do
      add(:order_id, references("snitch_orders", on_delete: :delete_all))
      add(:promotion_id, references("snitch_promotions"))
      add(:promotion_action_id, references("snitch_promotion_actions"))
      add(:adjustment_id, references("snitch_adjustments"))

      timestamps()
    end
  end
end
