defmodule Snitch.Repo.Migrations.AddInventoryTrackingField do
  use Ecto.Migration

  def change do
    alter table("snitch_products") do
      add(:inventory_tracking, InventoryTrackingEnum.type(), null: false, default: 0)
    end
  end
end
