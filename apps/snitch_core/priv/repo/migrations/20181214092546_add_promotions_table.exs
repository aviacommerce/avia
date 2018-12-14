defmodule Snitch.Repo.Migrations.AddPromotionsTable do
  use Ecto.Migration

  def change do
    create table("snitch_promotions") do
      add(:code, :string)
      add(:name, :string)
      add(:description, :string)
      add(:starts_at, :utc_datetime)
      add(:expires_at, :utc_datetime)
      add(:usage_limit, :integer, default: 0)
      add(:current_usage_count, :integer, default: 0)
      add(:match_policy, :string, default: "all")
      add(:active?, :boolean, default: false)

      timestamps()
    end

    create unique_index("snitch_promotions", :code)
  end
end
