defmodule SnitchApiWeb.ProductController do
  use SnitchApiWeb, :controller

  alias Snitch.Data.Schema.Product
  alias Snitch.Repo

  def index(conn, _params) do
    products =
      Repo.all(Product)
      |> Repo.preload(variants: [:images])

    render(conn, "products.json", products: products)
  end

  def show(conn, params) do
    product =
      Repo.get_by(Product, slug: params["id"])
      |> Repo.preload(variants: [:images])

    render(conn, "product.json", product: product)
  end
end
