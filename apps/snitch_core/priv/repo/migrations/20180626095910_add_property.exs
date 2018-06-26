defmodule Snitch.Repo.Migrations.AddProperty do
  use Ecto.Migration

  def change do
    create table("snitch_properties") do
      add :name, :string, null: false
      add :display_name, :string, null: false
      timestamps()
    end

    create unique_index("snitch_properties", [:name])
  end
end
