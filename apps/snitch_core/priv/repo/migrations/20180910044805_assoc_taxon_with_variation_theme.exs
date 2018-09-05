defmodule Snitch.Repo.Migrations.AssocTaxonWithVariationTheme do
  use Ecto.Migration

  def change do
    create table("snitch_taxon_themes") do
      add :taxon_id, references("snitch_taxons", on_delete: :delete_all), null: false
      add :variation_theme_id, references("snitch_variation_theme", on_delete: :delete_all), null: false
    end
  end
end
