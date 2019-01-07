defmodule Snitch.Repo.Migrations.AddPromotionRule do
  use Ecto.Migration

  def change do
    execute("CREATE EXTENSION IF NOT EXISTS citext")
    create table("snitch_promotion_rules") do
      add(:name, :citext, null: false)
      add(:module, PromotionRuleEnum.type(), null: false)
      add(:preferences, :map)
      add(:promotion_id, references("snitch_promotions"),
        null: false)

      timestamps()
    end

    create unique_index("snitch_promotion_rules", [:name, :promotion_id])
  end
end
