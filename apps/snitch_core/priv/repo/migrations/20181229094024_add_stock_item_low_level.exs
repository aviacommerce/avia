defmodule Snitch.Repo.Migrations.AddStockItemLowLevel do
  use Ecto.Migration

  def change do
    alter table("snitch_stock_items") do
      add(:inventory_warning_level, :integer, default: 0)
    end
  end
end
