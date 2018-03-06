defmodule Core.Repo.Migrations.AddStockLocationsTable do
  use Ecto.Migration

  def change do
    create table(:snitch_stock_locations) do
      add(:name, :string)

      add(:default, :boolean, default: false, null: false)
      add(:address_line_1, :string, null: false)
      add(:address_line_2, :string)

      add(:city, :string)

      add(:state_id, references(:snitch_states, on_delete: :delete_all))
      add(:country_id, references(:snitch_countries, on_delete: :delete_all))
      add(:zip_code, :string)
      add(:phone, :string)

      add(:backorderable_default, :boolean, default: false, null: false)

      # Checking this option when you create a new stock location will
      # loop through all of the products you already have in your store,
      # and create an entry for each one at your new location, with a
      # starting inventory amount of 0.
      add(:propagate_all_variants, :boolean, default: true, null: false)

      # Internal system name
      add(:admin_name, :string)

      add(:active, :boolean, default: true)

      timestamps()
    end

    create(index(:snitch_stock_locations, [:active]))
    create(index(:snitch_stock_locations, [:backorderable_default]))
    create(index(:snitch_stock_locations, [:country_id]))
    create(index(:snitch_stock_locations, [:propagate_all_variants]))
    create(index(:snitch_stock_locations, [:state_id]))
  end
end
