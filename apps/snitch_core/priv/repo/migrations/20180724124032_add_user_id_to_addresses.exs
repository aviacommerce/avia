defmodule Snitch.Repo.Migrations.AddUserIdToAddresses do
  use Ecto.Migration

  def change do
    alter table("snitch_addresses") do
      add :user_id, references(:snitch_users)
    end
  end
end
