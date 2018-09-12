defmodule Snitch.Repo.Migrations.CreateBrandImages do
  use Ecto.Migration

  def change do
    create table("snitch_product_brand_images") do
      add(:product_brand_id, references("snitch_product_brands", on_delete: :delete_all), null: false)
      add(:image_id, references("snitch_images", on_delete: :restrict), null: false)
      timestamps()
    end
  end
end
