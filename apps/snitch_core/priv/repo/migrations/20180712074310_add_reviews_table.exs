defmodule Snitch.Repo.Migrations.AddReviewsTable do
  use Ecto.Migration

  def change do
    create table(:snitch_reviews) do
      add(:title, :string)
      add(:description, :string, null: false)
      add(:approved, :boolean, default: false)
      add(:locale, :string)
      add(:name, :string, null: false)
      add(:user_id, references(:snitch_users, on_delete: :restrict), null: false)

      timestamps()
    end
  end
end
