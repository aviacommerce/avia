defmodule Snitch.Repo.Migrations.CreateShippingCategory do
  use Ecto.Migration

  def change do
    create table("snitch_shipping_categories") do
      add :name, :string, null: false

      timestamps()
    end

    create unique_index("snitch_shipping_categories", :name)

    alter table("snitch_variants") do
      add :shipping_category_id, references("snitch_shipping_categories", on_delete: :nothing)
    end
  end
end
