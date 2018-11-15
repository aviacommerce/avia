defmodule Snitch.Repo.Migrations.ChangePackageForTaxField do
  use Ecto.Migration

  def up do
    alter table("snitch_packages") do
      remove :total
      remove :tax_total
      remove :promo_total
      remove :adjustment_total
      add :shipping_tax, String.to_atom("money_with_currency")
    end

    alter table("snitch_package_items") do
      add :tax, String.to_atom("money_with_currency")
      add :shipping_tax, String.to_atom("money_with_currency")
    end
  end

  def down do
    alter table("snitch_packages") do
      add :total, String.to_atom("money_with_currency")
      add :tax_total, String.to_atom("money_with_currency")
      add :promo_total, String.to_atom("money_with_currency")
      add :adjustment_total, String.to_atom("money_with_currency")
      remove :shipping_tax
    end

    alter table("snitch_package_itemss") do
      remove :tax
      remove :shipping_tax
    end
  end
end
