defmodule Snitch.Repo.Migrations.AddImportProductDetails do
  use Ecto.Migration

  def change do
    alter table("snitch_products") do
      add :store, :string, null: false, default: "avia"
      add :import_product_id, :string
    end
  end
end
