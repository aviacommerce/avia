defmodule SnitchApiWeb.VariantController do
  use SnitchApiWeb, :controller

  alias Snitch.Data.Model.WishListItem
  alias Snitch.Data.Schema.Variant
  alias Snitch.Core.Tools.MultiTenancy.Repo

  def favorite_variants(conn, _params) do
    variants = Repo.all(WishListItem.most_favorited_variants())
    render(conn, "index.json-api", data: variants)
  end

  def index(conn, %{"product_id" => id}) do
    variants =
      Variant
      |> Repo.all(where: %{product_id: id})
      |> Repo.preload([:images, :shipping_category, :product, stock_items: :stock_location])

    render(
      conn,
      "index.json-api",
      data: variants,
      opts: [include: "images,stock_items,stock_items,shipping_category,product"]
    )
  end
end
