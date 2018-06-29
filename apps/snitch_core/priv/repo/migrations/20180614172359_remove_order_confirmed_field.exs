defmodule Snitch.Repo.Migrations.RemoveOrderConfirmedField do
  use Ecto.Migration

  def up do
    alter table("snitch_orders") do
      remove(:confirmed?)
    end
  end

  def down do
    alter table("snitch_orders") do
      add(:confirmed, :boolean, default: false)
    end
  end
end
