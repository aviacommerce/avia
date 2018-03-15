defmodule Snitch.Repo.Migrations.CreateShippingMethodTable do
  use Ecto.Migration

  def change do
    create table("snitch_shipping_methods") do
      add :slug, :string, null: :false
      add :name, :string, null: :false
      add :description, :text, null: false
      timestamps()
    end
    create unique_index("snitch_shipping_methods", :slug)

    create table("snitch_shipping_methods_zones") do
      add :shipping_method_id, references("snitch_shipping_methods", on_delete: :delete_all)
      add :zone_id, references("snitch_zones", on_delete: :delete_all)
    end
  end
end
