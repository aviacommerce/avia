defmodule Snitch.Repo.Migrations.AddPromotionAction do
  use Ecto.Migration

  def change do
    execute("CREATE EXTENSION IF NOT EXISTS citext")
    create table("snitch_promotion_actions") do
      add(:name, :citext, null: false)
      add(:module, PromotionRuleEnum.type(), null: false)
      add(:preferences, :map)
      add(:promotion_id, references("snitch_promotions"))

      timestamps()
    end

    create unique_index("snitch_promotion_actions", [:name, :promotion_id])
  end
end
