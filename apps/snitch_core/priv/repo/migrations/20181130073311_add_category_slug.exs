defmodule Snitch.Repo.Migrations.AddCategorySlug do
  use Ecto.Migration

  def change do
    alter table("snitch_taxons", null: false, default: "") do
      add(:slug, :string)
    end

    create(unique_index("snitch_taxons", [:slug]))
  end
end
