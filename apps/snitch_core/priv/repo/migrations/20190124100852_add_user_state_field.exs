defmodule Snitch.Repo.Migrations.AddUserStateField do
  use Ecto.Migration

  def change do
    alter table("snitch_users") do
      add(:state, UserStateEnum.type(), null: false, default: 0)
      add :deleted_at, :utc_datetime
    end
  end
end
