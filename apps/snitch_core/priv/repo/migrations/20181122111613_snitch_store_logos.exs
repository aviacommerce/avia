defmodule Snitch.Repo.Migrations.SnitchStoreLogos do
  use Ecto.Migration

  def change do
    create table("snitch_store_logos") do
      add(:general_configuration_id, references("snitch_general_configurations", on_delete: :delete_all), null: false)
      add(:image_id, references("snitch_images", on_delete: :restrict), null: false)
      timestamps()
    end
  end
end
