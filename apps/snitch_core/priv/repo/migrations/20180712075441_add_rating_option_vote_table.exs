defmodule Snitch.Repo.Migrations.AddRatingOptionVote do
  use Ecto.Migration

  def change do
    create table(:snitch_rating_option_votes) do
      add(:rating_option_id, references(:snitch_rating_options), null: false)
      add(:review_id, references(:snitch_reviews, on_delete: :delete_all), null: false)

      timestamps()
    end
  end
end
