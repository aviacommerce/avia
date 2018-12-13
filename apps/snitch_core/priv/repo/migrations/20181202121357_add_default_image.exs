defmodule Snitch.Repo.Migrations.AddDefaultImage do
  use Ecto.Migration

  def change do
    alter table("snitch_images") do
      add(:is_default, :boolean, default: false)
    end
  end
end
