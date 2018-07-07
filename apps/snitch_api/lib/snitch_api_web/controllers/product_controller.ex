defmodule SnitchApiWeb.ProductController do
  use SnitchApiWeb, :controller

  alias SnitchApi.API, as: Context

  action_fallback(SnitchApiWeb.FallbackController)

  # sort the products in Z-A descending order_by prodcut name
  def index(conn, %{"sort" => "Z-A"} = params) do
    {products, page} = Context.products_by_desc(params, conn)

    render(
      conn,
      "index.json-api",
      data: products,
      opts: [include: "variants,variants.images", page: page]
    )
  end

  # sort the products in A-Z ascending order_by prodcut name
  def index(conn, %{"sort" => "A-Z"} = params) do
    {products, page} = Context.products_by_asc(params, conn)

    render(
      conn,
      "index.json-api",
      data: products,
      opts: [include: "variants,variants.images", page: page]
    )
  end

  # sort the products in chronological order, in the order they inserted
  def index(conn, %{"sort" => "date"} = params) do
    {products, page} = Context.products_by_date_inserted(params, conn)

    render(
      conn,
      "index.json-api",
      data: products,
      opts: [include: "variants,variants.images", page: page]
    )
  end

  # filter products in the product name contains name
  def index(conn, %{"filter" => %{"name" => name}} = params) do
    {products, page} = Context.products_by_name_search(name, params, conn)

    render(
      conn,
      "index.json-api",
      data: products,
      opts: [include: "variants,variants.images", page: page]
    )
  end

  # fetches all products when the parmaters are empty /products
  def index(conn, _params) do
    {products, page} = Context.list_products(conn)

    render(
      conn,
      "index.json-api",
      data: products,
      opts: [include: "variants,variants.images", page: page]
    )
  end

  def show(conn, %{"product_slug" => slug}) do
    product = Context.product_by_slug!(slug)

    render(
      conn,
      "show.json-api",
      data: product,
      opts: [include: "variants,variants.images"]
    )
  end
end
