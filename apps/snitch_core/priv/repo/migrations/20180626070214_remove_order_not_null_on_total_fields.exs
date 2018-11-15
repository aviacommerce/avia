defmodule Snitch.Repo.Migrations.RemoveOrderNotNullOnTotalFields do
  use Ecto.Migration

  def up do
    alter table("snitch_orders") do
      modify :total, String.to_atom("money_with_currency"), null: true
      modify :item_total, String.to_atom("money_with_currency"), null: true
      modify :adjustment_total, String.to_atom("money_with_currency"), null: true
      modify :promo_total, String.to_atom("money_with_currency"), null: true
    end
  end

  def down do
    alter table("snitch_orders") do
      modify :total, String.to_atom("money_with_currency"), null: false
      modify :item_total, String.to_atom("money_with_currency"), null: false
      modify :adjustment_total, String.to_atom("money_with_currency"), null: false
      modify :promo_total, String.to_atom("money_with_currency"), null: false
    end
  end
end
