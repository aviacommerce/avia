defmodule Snitch.Repo.Migrations.AddRatingOptionTable do
  use Ecto.Migration

  def change do
    create table(:snitch_rating_options) do
      add(:code, :string, null: false)
      add(:value, :integer, null: false)
      add(:position, :integer, default: 0, null: false)
      add(:rating_id, references(:snitch_ratings, on_delete: :delete_all))

      timestamps()
    end
  end
end
