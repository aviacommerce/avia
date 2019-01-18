defmodule Snitch.Repo.Migrations.AlterTaxRelatedTables do
  use Ecto.Migration

  def up do
    alter table(:snitch_tax_categories) do
      modify(:name, :citext, null: false)
      modify(:tax_code, :citext, null: false)
    end

    create unique_index(:snitch_tax_categories, [:tax_code], where: "deleted_at is null")
    create unique_index(:snitch_tax_categories, [:is_default?],
      where: "is_default?", name: :default_tax_category_index)
  end

  def down do
    drop unique_index(:snitch_tax_categories, [:tax_code], where: "deleted_at is null")
    drop unique_index(:snitch_tax_categories, [:is_default?],
      where: "is_default? is true")
    alter table(:snitch_tax_categories) do
      modify(:name, :string)
      modify(:tax_code, :string)
    end
  end
end
