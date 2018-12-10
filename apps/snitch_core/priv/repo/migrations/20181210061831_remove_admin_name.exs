defmodule Snitch.Repo.Migrations.RemoveAdminName do
  use Ecto.Migration

  def change do
    alter table("snitch_stock_locations") do
      remove :admin_name
    end

    create unique_index("snitch_stock_locations", [:name])
  end
end

