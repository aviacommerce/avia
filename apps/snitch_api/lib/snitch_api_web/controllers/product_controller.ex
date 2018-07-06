defmodule SnitchApiWeb.ProductController do
  use SnitchApiWeb, :controller

  alias Snitch.Data.Schema.Product
  alias Snitch.Repo

  def index(conn, _params) do
    products =
      Repo.all(Product)
      |> Repo.preload(variants: [:images])

    render(
      conn,
      "index.json-api",
      data: products,
      opts: [include: "variants"]
    )
  end

  def show(conn, %{"product_slug" => product_slug}) do
    product =
      Repo.get_by(Product, slug: product_slug)
      |> Repo.preload(variants: [:images])

    render(
      conn,
      "show.json-api",
      data: product,
      opts: [include: "variants"]
    )
  end
end
