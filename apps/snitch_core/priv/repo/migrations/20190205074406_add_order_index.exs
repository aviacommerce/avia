defmodule Snitch.Repo.Migrations.AddOrderIndex do
  use Ecto.Migration

  def change do
    create index(:snitch_orders, ["updated_at DESC"])
  end
end
