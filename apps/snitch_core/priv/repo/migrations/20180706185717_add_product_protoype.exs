defmodule Snitch.Repo.Migrations.AddProductProtoype do
  use Ecto.Migration

  def change do
    create table("snitch_product_prototype") do
      add :name, :string, null: false
      add :taxon_id, references("snitch_taxons", on_delete: :restrict), null: false
      timestamps()
    end

    create table("snitch_prototype_property") do
      add :product_prototype_id, references("snitch_product_prototype", on_delete: :delete_all), null: false
      add :property_id, references("snitch_properties", on_delete: :delete_all), null: false
    end

    create table("snitch_prototype_themes") do
      add :product_prototype_id, references("snitch_product_prototype", on_delete: :delete_all), null: false
      add :variation_theme_id, references("snitch_variation_theme", on_delete: :delete_all), null: false
    end

    create unique_index("snitch_product_prototype", [:name])
  end
end
