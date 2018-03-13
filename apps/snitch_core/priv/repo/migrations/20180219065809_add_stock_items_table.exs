defmodule Core.Repo.Migrations.AddStockItemsTable do
  use Ecto.Migration

  def change do
    create table(:snitch_stock_items) do
      add :count_on_hand, :integer, default: 0, null: false
      add :stock_location_id, references(:snitch_stock_locations, on_delete: :delete_all)
      add :variant_id, references(:snitch_variants, on_delete: :delete_all)
      add :backorderable, :boolean, default: false

      timestamps()
    end

    create index(:snitch_stock_items, [:stock_location_id])
    create unique_index(
      :snitch_stock_items,
      [:stock_location_id, :variant_id],
      name: :snitch_stock_item_by_loc_and_var_id
    )
  end
end
