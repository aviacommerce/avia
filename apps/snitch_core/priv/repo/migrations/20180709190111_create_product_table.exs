defmodule Snitch.Repo.Migrations.CreateProductTable do
  use Ecto.Migration

  def change do

    create table("snitch_products") do
      add :name, :string, null: false, default: ""
      add :description, :text
      add :available_on, :utc_datetime
      add :deleted_at, :utc_datetime
      add :discontinue_on, :utc_datetime
      add :slug, :string, null: false
      add :meta_description, :string
      add :meta_keywords, :string
      add :meta_title, :string
      add :promotionable, :boolean
      timestamps()
    end

    create unique_index("snitch_products", [:slug])

    alter table("snitch_variants") do
      add :product_id, references("snitch_products", on_delete: :delete_all)
    end
  end
end
