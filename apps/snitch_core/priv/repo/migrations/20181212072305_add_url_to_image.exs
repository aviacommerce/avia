defmodule Snitch.Repo.Migrations.AddUrlToImage do
  use Ecto.Migration

  def change do
    alter table("snitch_images") do
      add(:image_url, :string)
    end
  end
end
