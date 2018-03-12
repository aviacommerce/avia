defmodule Snitch.Repo.Migrations.AddStockTransfersTable do
  use Ecto.Migration

  def change do
    create table(:snitch_stock_transfers) do
      add(:type, :string)
      add(:reference, :string)
      add(:source_location_id, references(:snitch_stock_locations))
      add(:destination_location_id, references(:snitch_stock_locations))
      add(:number, :string)

      timestamps()
    end

    create(unique_index(:snitch_stock_transfers, [:number]))
    create(index(:snitch_stock_transfers, [:destination_location_id]))
    create(index(:snitch_stock_transfers, [:source_location_id]))
  end
end
