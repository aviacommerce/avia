defmodule Core.Repo.Migrations.OrderBelongsToUser do
  use Ecto.Migration

  def change do
    alter table(:snitch_orders) do
      add :user_id, references("snitch_users"), null: false
    end
  end
end
