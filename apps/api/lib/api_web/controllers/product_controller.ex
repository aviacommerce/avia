defmodule ApiWeb.ProductController do
  use ApiWeb, :controller

  alias Snitch.Data.Schema.Product
  alias Snitch.Repo

  def index(conn, params) do
    products =
      Repo.all(Product)
      |> Repo.preload(variants: [:images])

    render(conn, "products.json", products: products)
  end

  def show(conn, params) do
    product =
      Repo.get_by(Product, slug: params["product_slug"])
      |> Repo.preload(variants: [:images])

    render(conn, "product.json", product: product)
  end
end
