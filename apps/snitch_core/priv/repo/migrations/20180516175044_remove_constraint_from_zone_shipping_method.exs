defmodule Snitch.Repo.Migrations.RemoveConstraintFromZone do
  use Ecto.Migration

  def change do
    alter table("snitch_zones") do
      remove :description
      add :description, :text
    end

    alter table("snitch_shipping_methods") do
      remove :description
      add :description, :text
    end
  end
end
