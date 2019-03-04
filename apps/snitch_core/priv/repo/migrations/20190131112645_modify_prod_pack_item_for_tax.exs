defmodule Snitch.Repo.Migrations.ModifyProdPackItemForTax do
  use Ecto.Migration

  def change do
    alter table("snitch_products") do
      add(:tax_class_id, references(:snitch_tax_classes, on_delete: :restrict))
    end

    alter table("snitch_package_items") do
      add(:unit_price, String.to_atom("money_with_currency"))
    end
  end
end
