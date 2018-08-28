defmodule Snitch.Repo.Migrations.AssocProductWithStockItem do
  use Ecto.Migration

  def change do
    alter table("snitch_stock_items") do
      remove :variant_id
      add :product_id, references("snitch_products", on_delete: :restrict)
    end
  end
end
