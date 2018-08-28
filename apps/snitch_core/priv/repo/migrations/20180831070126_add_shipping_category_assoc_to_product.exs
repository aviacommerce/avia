defmodule Snitch.Repo.Migrations.AddShippingCategoryAssocToProduct do
  use Ecto.Migration

  def change do
    alter table("snitch_products") do
      add(:shipping_category_id, references("snitch_shipping_categories"), on_delete: :restrict)
      add :height, :decimal, precision: 8, scale: 2
      add :width, :decimal, precision: 8, scale: 2
      add :depth, :decimal, precision: 8, scale: 2
      add :sku, :string, null: false, default: ""
      add :position, :integer
      add :weight, :decimal, precision: 8, scale: 2, default: 0.0
    end
  end
end
