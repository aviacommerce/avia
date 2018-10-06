defmodule Snitch.Data.Model.WishListTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase

  import Snitch.Factory

  alias Snitch.Data.Model.WishListItem
  alias Snitch.Core.Tools.MultiTenancy.Repo

  setup do
    user = insert(:user)
    [user: user]
  end

  setup :variants

  @tag variant_count: 1
  test "add item to wishlist", context do
    %{user: user} = context
    %{variants: variants} = context
    variant = List.first(variants)
    params = %{user_id: user.id, product_id: variant.id}
    assert {:ok, _} = WishListItem.create(params)
    {:error, changeset} = WishListItem.create(params)
    assert %{wishlist_item: ["product already in wishlist"]} == errors_on(changeset)
  end

  test "delete item from wishlist", context do
    %{user: user} = context
    %{variants: variants} = context
    variant = List.first(variants)
    params = %{user_id: user.id, product_id: variant.id}
    assert {:ok, item} = WishListItem.create(params)
    assert {:ok, _} = WishListItem.delete(item.id)
    assert {:error, :not_found} = WishListItem.delete(item.id)
  end

  test "favorite wishlist items", context do
    query = WishListItem.most_favorited_variants()
    items = Repo.all(query)
    assert items == []
    %{user: user1} = context
    user2 = insert(:user, role: %{name: "user"})
    variant1 = insert(:random_variant)
    variant2 = insert(:random_variant)

    {:ok, _} = WishListItem.create(%{user_id: user1.id, product_id: variant1.id})
    {:ok, _} = WishListItem.create(%{user_id: user2.id, product_id: variant1.id})
    {:ok, _} = WishListItem.create(%{user_id: user1.id, product_id: variant2.id})

    query = WishListItem.most_favorited_variants()
    [hd | _] = Repo.all(query)
    assert hd.id == variant1.id
  end
end
