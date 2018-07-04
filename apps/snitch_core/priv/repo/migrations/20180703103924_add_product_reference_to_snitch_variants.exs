defmodule Snitch.Repo.Migrations.AddProductReferenceToSnitchVariants do
  use Ecto.Migration

  def change do
    alter table("snitch_variants") do
      add :product_id, references("snitch_products")
    end

  end
end
