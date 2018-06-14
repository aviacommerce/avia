defmodule Snitch.Repo.Migrations.RenameOrderSlugToNumber do
  use Ecto.Migration

  def up do
    drop unique_index("snitch_orders", [:slug])
    rename table("snitch_orders"), :slug, to: :number
    create unique_index("snitch_orders", [:number])
  end

  def down do
    drop unique_index("snitch_orders", [:number])
    rename table("snitch_orders"), :number, to: :slug
    create unique_index("snitch_orders", [:slug])
  end
end
