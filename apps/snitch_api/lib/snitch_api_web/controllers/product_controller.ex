defmodule SnitchApiWeb.ProductController do
  use SnitchApiWeb, :controller

  alias Snitch.Repo
  alias Snitch.Data.Schema.Product

  import Ecto.Query, only: [from: 2]

  def index(conn, params) do
    {page_number, size} = extract_page_params(params)

    query = from(p in Product, select: p)

    page =
      query
      |> Repo.all()
      |> gen_page_links(params, conn)

<<<<<<< HEAD
  import Ecto.Query, only: [from: 2]

  # sort the products in Z-A descending order_by prodcut name
  def index(conn, %{"sort" => "Z-A"} = params) do
    query = from(p in Product, order_by: [desc: p.name])
    render_view(query, params, conn)
  end

  # sort the products in A-Z ascending order_by prodcut name
  def index(conn, %{"sort" => "A-Z"} = params) do
    query = from(p in Product, order_by: [asc: p.name])
    render_view(query, params, conn)
  end

  # sort the products in chronological order, in the order they inserted
  def index(conn, %{"sort" => "date"} = params) do
    query = from(p in Product, order_by: [desc: p.inserted_at])
    render_view(query, params, conn)
  end

  # filter products in the product name contains name
  def index(conn, %{"filter" => %{"name" => name}} = params) do
    query = from(p in Product, where: ilike(p.name, ^"%#{name}%"))
    render_view(query, params, conn)
  end

  # fetches all products when the parmaters are empty /products
  def index(conn, params = %{}) do
    query = from(p in Product, select: p)
    render_view(query, params, conn)
  end

  def show(conn, %{"product_slug" => slug} = params) do
    product =
      Product
      |> Repo.get_by(slug: slug)
=======
    products =
      query
      |> paginate(page_number, size)
      |> Repo.all()
>>>>>>> 53ea4bc... Products list pagination url links
      |> Repo.preload(variants: [:images])

    render(
      conn,
      "index.json-api",
<<<<<<< HEAD
      data: product,
      opts: [include: "variants,variants.images"]
    )
  end

  defp render_view(query, params, conn) do
    {page_number, size} = extract_page_params(params)

    page =
      query
      |> Repo.all()
      |> gen_page_links(params, conn)

    products =
      Repo.all(Product)
=======
      data: products,
      opts: [include: "variants,variants.images", page: page]
    )
  end

  def show(conn, %{"product_slug" => slug} = params) do
    IO.inspect(params, label: "............inside show....")

    product =
      Product
      |> Repo.get_by(slug: slug)
>>>>>>> 53ea4bc... Products list pagination url links
      |> Repo.preload(variants: [:images])

    render(
      conn,
      "index.json-api",
<<<<<<< HEAD
      data: products,
      opts: [include: "variants"]
    )
  end

  defp gen_page_links(collection, params, conn) do
    {number, size} = extract_page_params(params)

    JaSerializer.Builder.PaginationLinks.build(
      %{
        number: number,
        size: size,
        total: div(Enum.count(collection), size),
        base_url: "http://0.0.0.0:3000/api/v1/products"
      },
      conn
    )
  end
=======
      data: product,
      opts: [include: "variants,variants.images"]
    )
  end

  def gen_page_links(collection, params, conn) do
    {number, size} = extract_page_params(params)

    JaSerializer.Builder.PaginationLinks.build(
      %{
        number: number,
        size: size,
        total: div(Enum.count(collection), size),
        base_url: "http://0.0.0.0:3000/api/v1/products"
      },
      conn
    )
  end

  defp paginate(query, page_number, size) do
    from(
      query,
      limit: ^size,
      offset: ^((page_number - 1) * size)
    )
  end

  defp extract_page_params(params) do
    case params do
      %{"page" => page} ->
        {String.to_integer(page["offset"]), String.to_integer(page["limit"])}

      _ ->
        {1, Application.get_env(:ja_serializer, :page_size, 2)}
    end
  end
>>>>>>> 53ea4bc... Products list pagination url links
end
