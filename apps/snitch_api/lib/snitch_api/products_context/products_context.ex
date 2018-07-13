defmodule SnitchApi.ProductsContext do
  @moduledoc """
  The JSON-API context.
  """
  alias Snitch.Repo
  alias Snitch.Data.Schema.Product

  import Ecto.Query, only: [from: 2, order_by: 2]

  @doc """
  List out the all products
  """

  def list_products(conn) do
    with query <- from(p in Product, select: p),
         page = create_page(query, %{}, conn),
         products <- paginate_collection(query, %{}) do
      {products, page}
    end
  end

  @doc """
  Gives the product, with matched `slug` or raise an error :not_found
  """
  def product_by_slug!(slug) do
    Product
    |> Repo.get_by!(slug: slug)
    |> Repo.preload(variants: [:images])
  end

  def products_by_date_inserted(params, conn) do
    with query <- from(p in Product, order_by: [desc: p.inserted_at]),
         page = create_page(query, params, conn),
         products <- paginate_collection(query, params) do
      {products, page}
    end
  end

  def products_by_name_search(name, params, conn) do
    with query <- from(p in Product, where: ilike(p.name, ^"%#{name}%")),
         page = create_page(query, params, conn),
         products <- paginate_collection(query, params) do
      {products, page}
    end
  end

  @doc """
  Fetches the products, order by `name` in ascending order.
  """
  def products_by_asc(params, conn) do
    with query <- order_by(Product, asc: :name),
         page = create_page(query, params, conn),
         products <- paginate_collection(query, params) do
      {products, page}
    end
  end

  @doc """
  Fetches the products, order by `name` in descending order.
  """
  def products_by_desc(params, conn) do
    with query <- order_by(Product, desc: :name),
         page = create_page(query, params, conn),
         products <- paginate_collection(query, params) do
      {products, page}
    end
  end

  @doc """
  Creates the page. The page comprises all the related pagination links
  """
  def create_page(query, params, conn) do
    query
    |> Repo.all()
    |> gen_page_links(params, conn)
  end

  @doc """
  Executes the given `query` applying the page in params.
  """
  def paginate_collection(query, params) do
    {page_number, size} = extract_page_params(params)

    query
    |> paginate(page_number, size)
    |> Repo.all()
    |> Repo.preload(variants: [:images])
  end

  @doc """
  Generates the pagination links like `prev` `self` `next` `last` using 
  data-collection and params-page
  """
  def gen_page_links(collection, params, conn) do
    {number, size} = extract_page_params(params)

    JaSerializer.Builder.PaginationLinks.build(
      %{
        number: number,
        size: size,
        total: div(Enum.count(collection), size),
        base_url: "http://" <> get_base_url(conn) <> "/api/v1/products"
      },
      conn
    )
  end

  @doc """
  This develops the query according to the page parameters.
  """
  def paginate(query, page_number, size) do
    from(
      query,
      limit: ^size,
      offset: ^((page_number - 1) * size)
    )
  end

  @doc """
  This extracts the page parameters and converts to integer
  """
  def extract_page_params(params) do
    case params do
      %{"page" => page} ->
        {String.to_integer(page["offset"]), String.to_integer(page["limit"])}

      _ ->
        {1, Application.get_env(:ja_serializer, :page_size, 2)}
    end
  end

  def get_base_url(conn) do
    case conn.req_headers
         |> Enum.filter(fn {x, _y} -> x == "host" end)
         |> Enum.at(0) do
      {_, base_url} -> base_url
      _ -> ""
    end
  end
end
