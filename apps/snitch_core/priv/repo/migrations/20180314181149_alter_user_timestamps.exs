defmodule Snitch.Repo.Migrations.AlterUserTimestamps do
  use Ecto.Migration

  def change do
    alter table(:snitch_users) do
      modify(:inserted_at, :naive_datetime, type: :utc_datetime)
      modify(:updated_at, :naive_datetime, type: :utc_datetime)
    end
  end
end
