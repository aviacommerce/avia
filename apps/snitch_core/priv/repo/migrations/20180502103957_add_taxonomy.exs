defmodule Snitch.Repo.Migrations.AddTaxonomy do
  use Ecto.Migration

  def change do
    create table(:snitch_taxonomies) do
      add(:name, :string, null: false)
      timestamps()
    end

    create table(:snitch_taxons) do
      add(:name, :string, null: false)
      add(:taxonomy_id, references(:snitch_taxonomies, on_delete: :delete_all))
      add(:parent_id, :id)
      add(:lft, :integer)
      add(:rgt, :integer)
      timestamps()
    end

    create(index(:snitch_taxons, [:parent_id]))
    create(index(:snitch_taxons, [:taxonomy_id]))

    alter table(:snitch_taxonomies) do
      add(:root_id, references("snitch_taxons"))
    end
  end
end
