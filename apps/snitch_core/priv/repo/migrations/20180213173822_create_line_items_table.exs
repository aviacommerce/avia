defmodule Core.Repo.Migrations.CreateLineItemsTable do
  use Ecto.Migration

  def change do
    create table(:snitch_line_items) do
      add :quantity, :integer, null: false
      add :unit_price, String.to_atom("money_with_currency"), null: false
      add :total, String.to_atom("money_with_currency"), null: false
      timestamps()
    end
  end
end
