defmodule Snitch.Repo.Migrations.ProductVariationThemeAssoc do
  use Ecto.Migration

  def change do
    alter table("snitch_products") do
      add :theme_id, references("snitch_variation_theme", on_delete: :restrict)
    end
  end
end
