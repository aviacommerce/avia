defmodule Snitch.Repo.Migrations.AddProductOptionValues do
  use Ecto.Migration

  def change do
    create table("snitch_product_option_values") do
      add :value, :string
      add :display_name, :string
      add :option_type_id, references("snitch_option_types", on_delete: :delete_all), null: false
      add :product_id, references("snitch_products"), null: false
      timestamps()
    end
  end
end
