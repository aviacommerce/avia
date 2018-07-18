defmodule Snitch.Snitch.Repo.Migrations.Create.EventsTable do
  use Ecto.Migration

  def change do
    create table(:hydrus_events) do
      add(:user_id, :integer, null: false)
      add(:name, :string, null: false)
      add(:properties, :map, null: false)

      timestamps()
    end
  end
end
