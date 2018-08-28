defmodule Snitch.Repo.Migrations.AddProductAssocToWishlist do
  use Ecto.Migration

  def change do
    drop(index(:snitch_wishlist_items, [:variant_id, :user_id], name: :unique_wishlist_item))

    alter table("snitch_wishlist_items") do
      remove(:variant_id)
      add(:product_id, references("snitch_products"))
    end

    create(
      unique_index(:snitch_wishlist_items, [:product_id, :user_id], name: :unique_wishlist_item)
    )
  end
end
