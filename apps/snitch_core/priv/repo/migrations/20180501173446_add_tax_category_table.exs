defmodule Snitch.Repo.Migrations.AddTaxCategoryTable do
  use Ecto.Migration

  def up do
    create table(:snitch_tax_categories) do
      add :name, :string
      add :description, :string
      add :tax_code, :string
      add :is_default?, :boolean, default: false
      add :deleted_at, :utc_datetime, default: nil

      timestamps()
    end
    create unique_index(:snitch_tax_categories, [:name], where: "deleted_at is null")
  end

  def down do
    drop unique_index(:snitch_tax_categories, [:name], where: "deleted_at is null")
    drop table(:snitch_tax_categories)
  end
end
