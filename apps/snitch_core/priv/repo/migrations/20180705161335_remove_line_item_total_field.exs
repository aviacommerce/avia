defmodule Snitch.Repo.Migrations.RemoveLineItemTotalField do
  use Ecto.Migration

  def up do
    alter table("snitch_line_items") do
      remove :total
    end
  end

  def down do
    alter table("snitch_line_items") do
      add :total, String.to_atom("money_with_currency"), null: false
    end
  end
end
