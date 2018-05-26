defmodule Snitch.Repo.Migrations.OrderBelongsToAddressAndStockLocationsIndex do
  use Ecto.Migration

  def change do
    alter table("snitch_orders") do
      remove :billing_address_id
      remove :shipping_address_id

      add :billing_address_id, references("snitch_addresses", on_delete: :nothing)
      add :shipping_address_id, references("snitch_addresses", on_delete: :nothing)
    end

    create unique_index("snitch_stock_locations", [:admin_name])
  end
end
