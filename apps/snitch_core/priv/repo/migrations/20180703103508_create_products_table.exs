defmodule Snitch.Repo.Migrations.CreateProductsTable do
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

    create index("snitch_products", [:name, :available_on, :deleted_at, :discontinue_on])
    create unique_index("snitch_products", [:slug])
  end
end
