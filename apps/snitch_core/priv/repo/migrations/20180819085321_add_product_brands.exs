defmodule Snitch.Repo.Migrations.AddProductBrands do
  use Ecto.Migration

  def change do
    create table("snitch_product_brands") do
      add :name, :string
      timestamps()
    end
  end

end
