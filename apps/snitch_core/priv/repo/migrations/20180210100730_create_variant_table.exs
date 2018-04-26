defmodule Core.Repo.Migrations.CreateVariantTable do
  use Ecto.Migration

  def change do
    create table(:snitch_variants) do
      add :sku, :string, null: false, default: ""
      add :weight, :decimal, precision: 8, scale: 2, default: 0.0
      add :height, :decimal, precision: 8, scale: 2
      add :width, :decimal, precision: 8, scale: 2
      add :depth, :decimal, precision: 8, scale: 2
      add :is_master, :boolean, default: false
      add :cost_price, :decimal, precision: 10, scale: 2
      add :position, :integer
      add :cost_currency, :string
      add :track_inventory, :boolean, default: true
      add :discontinue_on, :utc_datetime

      # Not adding any association ids
      timestamps()
    end
  end
end
