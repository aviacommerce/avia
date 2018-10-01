defmodule Snitch.Repo.Migrations.AssocProductWithProperty do
  use Ecto.Migration

  def change do
    create table("snitch_product_properties") do
      add(:product_id, references("snitch_products"), null: false, on_delete: :restrict)
      add(:property_id, references("snitch_properties"), null: false, on_delete: :restrict)
      add(:value, :string, null: false)
      timestamps()
    end

    create(
      unique_index(
        :snitch_product_properties,
        [:property_id, :product_id],
        name: :unique_property_per_product
      )
    )
  end
end
