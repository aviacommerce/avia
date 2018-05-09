defmodule Snitch.Repo.Migrations.AddTaxRateTable do
  use Ecto.Migration

  def change do
    create  table(:snitch_tax_rates) do
      add :name, :string, null: false
      add :value, :decimal, null: false
      add :calculator, :string, null: false
      add :deleted_at, :utc_datetime
      add :included_in_price, :boolean
      add :tax_category_id, references(:snitch_tax_categories), null: false
      add :zone_id, references(:snitch_zones), null: false

      timestamps()
    end

    create unique_index(:snitch_tax_rates, [:name, :zone_id],
      name: :unique_name_per_zone)
  end
end
