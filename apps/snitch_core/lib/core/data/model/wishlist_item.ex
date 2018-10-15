defmodule Snitch.Data.Model.WishListItem do
  @moduledoc """
  API for User Wishlist.
  """

  use Snitch.Data.Model
  alias Snitch.Data.Schema.Product
  alias Snitch.Data.Schema.WishListItem

  @doc """
  Adds an item(variant) to a wishlist for a user.

  Takes as input `user_id` and `variant_id`.
  Returns a wishlist item struct.

  ## Note
  A variant can be added as a wishlist item only once
  by a user.
  """
  @spec create(map) :: {:ok, WishListItem.t()} | {:error, Ecto.Changeset.t()}
  def create(params) do
    QH.create(WishListItem, params, Repo)
  end

  @doc """
  Deletes a wishlist item.

  Takes as input `id` or `struct` of the wishlist_item to be deleted.
  """
  @spec delete(non_neg_integer) ::
          {:ok, WishListItem.t()}
          | {:error, Ecto.ChangeSet.t()}
          | {:error, :not_found}
  @spec delete(non_neg_integer) :: {}
  def delete(id) do
    QH.delete(WishListItem, id, Repo)
  end

  @doc """
  Returns a query.

  The query on execution returns a list of variants.
  The order of the variants in the list is determined by
  preference of users to add a variant as wishlist
  item.
  The most preferred variants are in the beginning
  of the list while the least are towards the end.
  """
  @spec most_favorited_variants() :: Ecto.Queryable.t()
  def most_favorited_variants do
    query =
      from(
        item in WishListItem,
        group_by: item.product_id,
        select: item.product_id,
        order_by: [desc: count(item.id)]
      )
      |> Map.put(:prefix, Repo.get_prefix())

    from(
      variant in Product,
      join: item in subquery(query),
      where: item.product_id == variant.id,
      select: variant
    )
  end
end
