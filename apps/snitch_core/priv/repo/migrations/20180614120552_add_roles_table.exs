defmodule Snitch.Repo.Migrations.AddRolesTable do
  use Ecto.Migration

  def change do
    create table(:snitch_roles) do
      add(:name, :string, null: false)
      add(:description, :string)

      timestamps()
    end

    create unique_index(:snitch_roles, :name)

    alter table(:snitch_users) do
      add(:role_id, references(:snitch_roles, on_delete: :nothing))
    end
  end
end
