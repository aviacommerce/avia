defmodule Snitch.Repo.Migrations.AssocProductWithTaxon do
  use Ecto.Migration

  def change do
    alter table("snitch_products") do
      add :taxon_id, references("snitch_taxons", on_delete: :restrict)
    end
  end
end
