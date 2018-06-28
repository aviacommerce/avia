defmodule Snitch.Repo.Migrations.EmbedOrderAddress do
  use Ecto.Migration

  def change do
    alter table(:snitch_orders) do
      add :billing_address, :map
      add :shipping_address, :map
    end
  end
end
