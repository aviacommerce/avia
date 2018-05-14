defmodule Snitch.Repo.Migrations.AssociateShippingCategoryAndShippingMethods do
  use Ecto.Migration

  def change do
    create table("snitch_shipping_methods_categories") do
      add :shipping_method_id, references("snitch_shipping_methods", on_delete: :delete_all)
      add :shipping_category_id, references("snitch_shipping_categories", on_delete: :delete_all)
    end

    create unique_index("snitch_shipping_methods_categories", [:shipping_method_id, :shipping_category_id])
    create unique_index("snitch_shipping_methods_zones", [:shipping_method_id, :zone_id])
  end
end
