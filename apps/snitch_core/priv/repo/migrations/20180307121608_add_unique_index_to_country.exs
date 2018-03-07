defmodule Snitch.Repo.Migrations.AddUniqueIndexToCountry do
  use Ecto.Migration

  def change do
    create unique_index(:snitch_countries, [:iso])
    create unique_index(:snitch_countries, [:iso3])
    create unique_index(:snitch_countries, [:name])
    create unique_index(:snitch_countries, [:numcode])
  end
end
