defmodule SnitchApiWeb.WishListItemController do
  use SnitchApiWeb, :controller

  alias Snitch.Data.Model.WishListItem
  alias Snitch.Core.Tools.MultiTenancy.Repo

  plug(SnitchApiWeb.Plug.DataToAttributes)
  # plug(SnitchApiWeb.Plug.LoadUser)

  action_fallback(SnitchApiWeb.FallbackController)

  def index(conn, _params) do
    with user when not is_nil(user) <- conn.assigns[:current_user] do
      user = Repo.preload(user, wishlist_items: [:variant])

      conn
      |> put_status(200)
      |> render(
        "index.json-api",
        data: user.wishlist_items
      )
    else
      nil ->
        conn
        |> put_status(:not_found)
        |> render(SnitchApiWeb.ErrorView, :"404")
    end
  end

  def create(conn, params) do
    %{"variant_id" => variant_id} = params
    %{"user_id" => user_id} = params

    attributes = %{
      variant_id: variant_id,
      user_id: user_id
    }

    with {:ok, wishlist_item} <- WishListItem.create(attributes) do
      wishlist_item = Repo.preload(wishlist_item, [:user, :variant])
      render(conn, "show.json-api", data: wishlist_item)
    end
  end

  def delete(conn, %{"id" => id}) do
    with {:ok, _} <- WishListItem.delete(id) do
      send_resp(conn, :no_content, "")
    end
  end
end
