defmodule SnitchApiWeb.VariantController do
  use SnitchApiWeb, :controller

  alias Snitch.Data.Model.WishListItem
  alias Snitch.Repo

  def favorite_variants(conn, _params) do
    variants = Repo.all(WishListItem.most_favorited_variants())
    render(conn, "index.json-api", data: variants)
  end
end
