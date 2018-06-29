defmodule Snitch.Repo.Migrations.AddOptionType do
  use Ecto.Migration

  def change do
    create table("snitch_option_types") do
      add :name, :string
      add :display_name, :string
      timestamps()
    end

    create table("snitch_template_option_values") do
      add :value, :string
      add :display_name, :string
      add :option_type_id, references("snitch_option_types", on_delete: :delete_all), null: false
      timestamps()
    end

    create unique_index("snitch_option_types", [:name])
  end
end
