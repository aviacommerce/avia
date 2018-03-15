defmodule Snitch.Repo.Migrations.RenameUsersIsAdminField do
  use Ecto.Migration

  def change do
    rename(table(:snitch_users), :is_admin?, to: :is_admin)
  end

  def down do
    rename(table(:snitch_users), :is_admin, to: :is_admin?)
  end
end
