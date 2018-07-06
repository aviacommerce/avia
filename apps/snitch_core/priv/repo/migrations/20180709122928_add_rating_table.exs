defmodule Snitch.Repo.Migrations.AddRatingTable do
  use Ecto.Migration

  def change do
    create table(:snitch_ratings) do
      add(:code, :string, null: false)
      add(:position, :integer, default: 0, null: false)

      timestamps()
    end

    create unique_index(:snitch_ratings, :code)
  end
end
