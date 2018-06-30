defmodule Snitch.Repo.Migrations.AddVariationTheme do
  use Ecto.Migration

  def change do
    create table("snitch_variation_theme") do
      add :name, :string, null: false
      timestamps()
    end

    create table("snitch_theme_option_types") do
      add :option_type_id, references("snitch_option_types", on_delete: :delete_all), null: false
      add :variation_theme_id, references("snitch_variation_theme", on_delete: :delete_all), null: false
    end

    create unique_index("snitch_variation_theme", [:name])
  end
end
