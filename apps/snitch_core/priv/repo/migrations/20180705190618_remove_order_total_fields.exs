defmodule Snitch.Repo.Migrations.RemoveOrderTotalFields do
  use Ecto.Migration

  def up do
    alter table("snitch_orders") do
      remove :total
      remove :item_total
      remove :promo_total
      remove :adjustment_total
    end
  end

  def down do
    alter table("snitch_orders") do
      add :total, String.to_atom("money_with_currency")
      add :item_total, String.to_atom("money_with_currency")
      add :promo_total, String.to_atom("money_with_currency")
      add :adjustment_total, String.to_atom("money_with_currency")
    end
  end
end
