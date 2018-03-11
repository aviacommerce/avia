defmodule Snitch.Repo.Migrations.AddStockMovementsTable do
  use Ecto.Migration

  def change do
    create table(:snitch_stock_movements) do
      add(:quantity, :integer, default: 0, null: false)
      add(:action, :string)
      add(:stock_item_id, references(:snitch_stock_items, on_delete: :delete_all))
      add(:originator_id, :integer)
      add(:originator_type, :string)

      timestamps()
    end

    create(index(:snitch_stock_movements, [:stock_item_id]))
    create(index(:snitch_stock_movements, [:originator_id, :originator_type]))
  end
end
