defmodule Core.Repo.Migrations.CreateSnitchCountries do
  use Ecto.Migration

  def change do
    create table(:snitch_countries) do
      add :iso_name, :string
      add :iso, :string
      add :iso3, :string
      add :name, :string
      add :numcode, :string
      add :states_required, :boolean, default: false

      timestamps()
    end
  end
end
