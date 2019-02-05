defmodule Snitch.Repo.Migrations.AddOrderIndex do
  use Ecto.Migration

  def change do
    create index(:snitch_orders, ["inserted_at DESC"])
  end
end
