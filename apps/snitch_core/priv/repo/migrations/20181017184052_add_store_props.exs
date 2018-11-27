defmodule Snitch.Repo.Migrations.AddStoreProps do
  use Ecto.Migration

  def change do
    create table("snitch_store_props") do
      add :key, :string, null: false
      add :value, :string, null: false
      timestamps()
    end
  end
end
