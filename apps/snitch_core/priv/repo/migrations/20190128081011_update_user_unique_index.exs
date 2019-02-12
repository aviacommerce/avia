defmodule Snitch.Repo.Migrations.UpdateUserUniqueIndex do
  use Ecto.Migration

  def change do
    drop unique_index("snitch_users", [:email])
    create unique_index("snitch_users", [:email, :deleted_at],  name: :unique_email)
  end
end
