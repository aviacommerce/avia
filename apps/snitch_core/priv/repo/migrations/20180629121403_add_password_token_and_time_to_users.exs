defmodule Snitch.Repo.Migrations.AddPasswordTokenAndTimeToUsers do
  use Ecto.Migration

  def change do
    alter table(:snitch_users) do
      add :reset_password_token, :string
      add :reset_password_sent_at, :datetime

    end
  end
end
