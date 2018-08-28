defmodule Snitch.Data.Schema.WishListItemTest do
  use ExUnit.Case
  use Snitch.DataCase
  import Snitch.Factory

  alias Snitch.Data.Schema.WishListItem

  setup do
    user = insert(:user)
    [user: user]
  end

  setup :variants

  @tag variant_count: 1
  test "creation successful", context do
    {user, variant} = prepare_user_variant(context)
    params = %{user_id: user.id, product_id: variant.id}
    %{valid?: valid} = changeset = WishListItem.create_changeset(%WishListItem{}, params)
    assert valid
    assert {:ok, _} = Repo.insert(changeset)
  end

  test "creation fails for missing params" do
    params = %{}
    %{valid?: validity} = changeset = WishListItem.create_changeset(%WishListItem{}, params)
    refute validity
    assert %{user_id: ["can't be blank"], product_id: ["can't be blank"]} = errors_on(changeset)
  end

  defp prepare_user_variant(context) do
    %{user: user} = context
    %{variants: variants} = context
    {user, List.first(variants)}
  end
end
