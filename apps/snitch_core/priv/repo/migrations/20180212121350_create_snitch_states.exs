defmodule Core.Repo.Migrations.CreateSnitchStates do
  use Ecto.Migration

  def change do
    create table(:snitch_states) do
      add :name, :string
      add :abbr, :string
      add :country_id, references(:snitch_countries, on_delete: :delete_all)

      timestamps()
    end
  end
end
