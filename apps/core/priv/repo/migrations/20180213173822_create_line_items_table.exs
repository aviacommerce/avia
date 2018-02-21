defmodule Core.Repo.Migrations.CreateLineItemsTable do
  use Ecto.Migration

  def change do
    create table(:snitch_line_items) do
      add :quantity, :integer, null: false
      add :unit_price, :money_with_currency, null: false
      add :total, :money_with_currency, null: false
      timestamps()
    end
  end
end
