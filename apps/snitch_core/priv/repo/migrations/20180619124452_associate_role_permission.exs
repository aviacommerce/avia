defmodule Snitch.Repo.Migrations.AssociateRolePermission do
  use Ecto.Migration

  def change do
    create table(:role_permissions) do
      add(:role_id, references(:snitch_roles, on_delete: :delete_all))
      add(:permission_id, references(:snitch_permissions))

      timestamps()
    end
  end
end
