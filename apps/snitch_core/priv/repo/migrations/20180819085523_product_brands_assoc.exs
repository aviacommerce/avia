defmodule Snitch.Repo.Migrations.ProductBrandsAssoc do
  use Ecto.Migration

  def change do
    alter table("snitch_products") do
      add :brand_id, references("snitch_product_brands", on_delete: :restrict)
    end
  end
end
