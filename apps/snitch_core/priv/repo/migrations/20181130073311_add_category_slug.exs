defmodule Snitch.Repo.Migrations.AddCategorySlug do
  use Ecto.Migration

  def change do
    alter table("snitch_taxons") do
      add :slug, :string, null: false, default: ""
    end
    
    create unique_index("snitch_taxons", [:slug])
  end
end
