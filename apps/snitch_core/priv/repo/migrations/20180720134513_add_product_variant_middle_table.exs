defmodule Snitch.Repo.Migrations.AddProductVariantMiddleTable do
  use Ecto.Migration

  def change do
    create table("snitch_product_variants") do
      add :parent_product_id, references("snitch_products", on_delete: :restrict), null: false
      add :child_product_id, references("snitch_products", on_delete: :delete_all), null: false
    end
  end
end
