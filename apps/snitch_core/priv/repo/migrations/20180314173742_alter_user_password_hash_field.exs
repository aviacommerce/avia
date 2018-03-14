defmodule Snitch.Repo.Migrations.AlterUserPasswordHashField do
  use Ecto.Migration

  def change do
    alter table(:snitch_users) do
      modify(:password_hash, :string, null: false)
    end
  end
end
