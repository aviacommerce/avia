defmodule Snitch.Repo.Migrations.AlterProductsTable do
  use Ecto.Migration

  def change do
     drop unique_index("snitch_products", [:slug])
     create unique_index("snitch_products", [:slug, :deleted_at])
  end
end
