defmodule Snitch.Repo.Migrations.AlterProductReviewsTable do
  use Ecto.Migration

  def change do
    alter table("snitch_product_reviews") do
      add(:user_id, references(:snitch_users, on_delete: :restrict), null: false)
    end

    create unique_index("snitch_product_reviews", [:user_id])
  end
end
