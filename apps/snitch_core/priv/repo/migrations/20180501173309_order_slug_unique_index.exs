defmodule Snitch.Repo.Migrations.OrderSlugUniqueIndex do
  use Ecto.Migration

  def change do
    create unique_index("snitch_orders", :slug)
  end
end
