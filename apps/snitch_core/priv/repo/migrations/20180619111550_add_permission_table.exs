defmodule Snitch.Repo.Migrations.AddPermissionTable do
  use Ecto.Migration

  def change do
    create table(:snitch_permissions) do
      add(:code, :string, null: false)
      add(:description, :string)

      timestamps()
    end

    create unique_index(:snitch_permissions, :code)
  end
end
