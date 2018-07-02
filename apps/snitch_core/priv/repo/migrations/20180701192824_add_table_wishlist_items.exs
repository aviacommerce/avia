defmodule Snitch.Repo.Migrations.AddTableWishlistItems do
  use Ecto.Migration

  def change do
    create table(:snitch_wishlist_items) do
      add(:variant_id, references(:snitch_variants, on_delete: :delete_all),
      null: false)
      add(:user_id, references(:snitch_users, on_delete: :delete_all),
        null: false)
      timestamps()
    end

    create unique_index(:snitch_wishlist_items,
            [:variant_id, :user_id], name: :unique_wishlist_item)
  end
end
