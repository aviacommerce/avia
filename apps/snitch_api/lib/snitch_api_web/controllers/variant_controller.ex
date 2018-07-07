defmodule SnitchApiWeb.VariantController do
  use SnitchApiWeb, :controller

  alias Snitch.Repo
  alias Snitch.Data.Schema.Variant

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
