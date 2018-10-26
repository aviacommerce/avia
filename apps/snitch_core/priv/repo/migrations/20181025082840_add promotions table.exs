defmodule :"Elixir.Snitch.Repo.Migrations.Add promotions table" do
  use Ecto.Migration

  def change do
    create table("snitch_promotions") do
      add(:code, :string)
      add(:description, :string)
      add(:starts_at, :utc_datetime)
      add(:expires_at, :utc_datetime)
      add(:usage_limit, :integer, default: 0)
      add(:current_usage_count, :integer, default: 0)
      add(:match_policy, :string, default: "all")
      add(:active, :boolean, default: false)
      add(:rules, {:array, :map}, default: [])
      add(:actions, {:array, :map}, default: [])

      timestamps()
    end

    create unique_index("snitch_promotions", :code)
  end
end
