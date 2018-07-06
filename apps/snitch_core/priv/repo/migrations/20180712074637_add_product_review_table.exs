defmodule Snitch.Repo.Migrations.AddProductReviewTable do
  use Ecto.Migration

  def change do
    create table("snitch_product_reviews") do
      add(:product_id, references(:snitch_products, on_delete: :delete_all), null: false)
      add(:review_id, references(:snitch_reviews, on_delete: :delete_all), null: false)

      timestamps()
    end
  end
end
