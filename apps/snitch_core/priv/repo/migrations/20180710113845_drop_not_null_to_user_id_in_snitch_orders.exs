defmodule Snitch.Repo.Migrations.DropNotNullToUserIdInSnitchOrders do
  use Ecto.Migration

  def change do
    alter table("snitch_orders") do
      modify :user_id, :integer, null: true
    end
  end
end
