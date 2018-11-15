defmodule Core.Repo.Migrations.CreateOrdersTable do
  use Ecto.Migration

  def change do
    create table(:snitch_orders) do
      add :slug, :string, null: false
      add :state, :string, default: "cart"
      add :special_instructions, :string
      add :confirmed?, :boolean, default: false

      # various prices and totals
      add :total, String.to_atom("money_with_currency"), null: false
      add :item_total, String.to_atom("money_with_currency"), null: false
      add :adjustment_total, String.to_atom("money_with_currency"), null: false
      add :promo_total, String.to_atom("money_with_currency"), null: false
      timestamps()
    end
  end
end
