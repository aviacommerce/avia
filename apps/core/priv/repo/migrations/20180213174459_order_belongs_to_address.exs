defmodule Core.Repo.Migrations.OrderBelongsToAddress do
  use Ecto.Migration

  def change do
    alter table(:snitch_orders) do
      add :billing_address_id, references("snitch_addresses")
      add :shipping_address_id, references("snitch_addresses")
    end
  end
end
