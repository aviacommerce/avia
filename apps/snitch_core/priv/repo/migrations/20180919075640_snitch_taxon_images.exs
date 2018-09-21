defmodule Snitch.Repo.Migrations.SnitchTaxonImages do
  use Ecto.Migration

  def change do
    create table("snitch_taxon_images") do
      add(:taxon_id, references("snitch_taxons", on_delete: :delete_all), null: false)
      add(:image_id, references("snitch_images", on_delete: :restrict), null: false)
      timestamps()
    end
  end
end
