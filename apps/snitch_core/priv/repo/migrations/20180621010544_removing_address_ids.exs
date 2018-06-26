defmodule Snitch.Repo.Migrations.RemovingAddressIds do
  use Ecto.Migration

  def change do
    alter table("snitch_orders") do
      remove :billing_address_id
      remove :shipping_address_id
    end

  end
end
