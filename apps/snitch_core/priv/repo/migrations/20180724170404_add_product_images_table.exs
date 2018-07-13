defmodule Snitch.Repo.Migrations.AddProductImagesTable do
  use Ecto.Migration

  def change do
    create table("snitch_product_images") do
      add :product_id, references("snitch_products", on_delete: :delete_all), null: false
      add :image_id, references("snitch_images", on_delete: :delete_all), null: false
    end
  end
end
