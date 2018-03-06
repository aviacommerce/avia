defmodule Core.Repo.Migrations.AddStockLocationsTable do
  use Ecto.Migration

  def change do
    create table(:snitch_stock_locations) do
      add :name, :string
      add :address_id, references(:snitch_addresses, on_delete: :delete_all)

      timestamps()
    end

    create index(:snitch_stock_locations, [:address_id])
  end
end
