defmodule Snitch.Data.Schema.WishListItem do
  @moduledoc """
  Models a Wishlist Item.
  """
  use Snitch.Data.Schema
  alias Snitch.Data.Schema.{User, Variant}

  @type t :: %__MODULE__{}

  schema "snitch_wishlist_items" do
    belongs_to(:user, User)
    belongs_to(:variant, Variant)
    timestamps()
  end

  @required_params ~w(variant_id user_id)a

  def create_changeset(%__MODULE__{} = wishlist, params) do
    wishlist
    |> cast(params, @required_params)
    |> validate_required(@required_params)
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:variant_id)
    |> unique_constraint(
      :wishlist_item,
      name: :unique_wishlist_item,
      message: "product already in wishlist"
    )
  end
end
