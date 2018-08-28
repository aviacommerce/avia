defmodule Snitch.Data.Schema.WishListItem do
  @moduledoc """
  Models a Wishlist Item.
  """
  use Snitch.Data.Schema
  alias Snitch.Data.Schema.{User, Product}

  @type t :: %__MODULE__{}

  schema "snitch_wishlist_items" do
    belongs_to(:user, User)
    belongs_to(:product, Product)
    timestamps()
  end

  @required_params ~w(product_id user_id)a

  def create_changeset(%__MODULE__{} = wishlist, params) do
    wishlist
    |> cast(params, @required_params)
    |> validate_required(@required_params)
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:product_id)
    |> unique_constraint(
      :wishlist_item,
      name: :unique_wishlist_item,
      message: "product already in wishlist"
    )
  end
end
