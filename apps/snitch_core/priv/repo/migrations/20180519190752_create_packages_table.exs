defmodule Snitch.Repo.Migrations.CreatePackagesTable do
  use Ecto.Migration

  def change do
    create table("snitch_packages") do
      add :number, :string, null: false
      add :state, :string, null: false
      add :shipped_at, :utc_datetime
      add :tracking, :map
      add :shipping_methods, :jsonb, default: "[]"
      add :cost, String.to_atom("money_with_currency")
      add :total, String.to_atom("money_with_currency")
      add :tax_total, String.to_atom("money_with_currency")
      add :adjustment_total, String.to_atom("money_with_currency")
      add :promo_total, String.to_atom("money_with_currency")

      add :order_id, references("snitch_orders", on_delete: :nothing), null: false
      add :origin_id, references("snitch_stock_locations", on_delete: :nothing), null: false
      add :shipping_category_id, references("snitch_shipping_categories", on_delete: :nothing), null: false
      add :shipping_method_id, references("snitch_shipping_methods", on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create unique_index("snitch_packages", [:number])

    alter table("snitch_package_items") do
      add :package_id, references("snitch_packages", on_delete: :delete_all), null: false
    end
  end
end
