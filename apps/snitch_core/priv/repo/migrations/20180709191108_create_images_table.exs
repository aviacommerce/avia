defmodule Snitch.Repo.Migrations.CreateImagesTable do
  use Ecto.Migration

  def change do
    create table("snitch_images") do
      add :name, :string, null: false
      timestamps()
    end

    create table("snitch_variant_images") do
      add :variant_id, references("snitch_variants", on_delete: :delete_all), null: false
      add :image_id, references("snitch_images", on_delete: :delete_all), null: false
    end
  end
end
