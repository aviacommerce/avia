defmodule Snitch.Repo.Migrations.CreateProtyotypeHierarchy do
  use Ecto.Migration

  def change do
    create table("snitch_products") do
      add :name, :string, null: false, default: ""
      add :description, :text
      add :available_on, :utc_datetime
      add :deleted_at, :utc_datetime
      add :discontinue_on, :utc_datetime
      add :slug, :string
      add :meta_description, :string
      add :meta_keywords, :string
      add :meta_title, :string
      add :promotionable, :boolean
      timestamps()
    end

    create table("snitch_properties") do
      add :name, :string
      add :display_name, :string, null: false
      timestamps()
    end

    create table("snitch_product_properties") do
      add :product_id, references("snitch_products")
      add :property_id, references("snitch_properties")
      add :value, :string
    end

    create table("snitch_option_types") do
      add :name, :string
      add :display_name, :string
      timestamps()
    end

    create table("snitch_option_values") do
      add :position, :integer
      add :name, :string
      add :display_name, :string
      add :option_type_id, references("snitch_option_types", on_delete: :delete_all), null: false
      timestamps()
    end

    create table("snitch_prototypes") do
      add :name, :string
      timestamps()
    end

    create table("snitch_option_type_prototypes") do
      add :option_type_id, references("snitch_option_types")
      add :prototype_id, references("snitch_prototypes")
    end

    create table("snitch_property_prototypes") do
      add :property_id, references("snitch_properties")
      add :prototype_id, references("snitch_prototypes")
    end

    create index("snitch_products", [:name, :available_on, :deleted_at, :discontinue_on])
    create unique_index("snitch_products", [:slug])
    create index("snitch_properties", [:name])
    create index("snitch_option_types", [:name])
    create index("snitch_option_values", [:name, :position, :option_type_id])

    alter table("snitch_variants") do
      add :product_id, references("snitch_products")
    end

    # only for demo
    create table("snitch_variant_images") do
      add :url, :string
      add :variant_id, references(:snitch_variants)
    end
  end
end
