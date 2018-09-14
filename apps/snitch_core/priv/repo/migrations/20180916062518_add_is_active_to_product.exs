defmodule Snitch.Repo.Migrations.AddIsActiveToProduct do
  use Ecto.Migration

  def change do
    alter table("snitch_products") do
      add :is_active, :boolean, default: true
    end
  end
end
