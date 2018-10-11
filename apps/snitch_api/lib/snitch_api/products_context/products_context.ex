defmodule SnitchApi.ProductsContext do
  @moduledoc """
  The JSON-API context.
  """
  alias Snitch.Core.Tools.MultiTenancy.Repo
  alias Snitch.Data.Schema.{Product, Review}

  import Ecto.Query, only: [from: 2, order_by: 2]

  @doc """
  List out all the products
  """
  def list_products(conn, params) do
    query = define_query(params)
    query = from(p in query, where: p.is_active == true)
    page = create_page(query, %{}, conn)
    products = paginate_collection(query, params)
    {products, page}
  end

  @doc """
  Gives the product with matched `slug` as {:ok, product} tuple or 
  returns an {:error, :not_found} tuple if product is not found.
  """
  @spec product_by_slug(String.t()) :: map
  def product_by_slug(slug) do
    case Repo.get_by(Product, slug: slug) do
      nil ->
        {:error, :not_found}

      product ->
        review_query = from(c in Review, limit: 5, preload: [rating_option_vote: :rating_option])

        product =
          product
          |> Repo.preload(
            reviews: review_query,
            variants: [:images, options: :option_type, theme: [:option_types]],
            theme: [:option_types],
            options: :option_type
          )

        {:ok, product}
    end
  end

  def product_by_brand(brand_id) do
    query = from(p in Product, where: p.brand_id == ^brand_id and p.is_active == true)

    review_query = from(c in Review, limit: 5, preload: [rating_option_vote: :rating_option])

    product =
      Repo.all(query)
      |> Repo.preload(
        reviews: review_query,
        variants: [:images, options: :option_type, theme: [:option_types]],
        theme: [:option_types],
        options: :option_type
      )
  end

  def product_by_taxon(taxon_id) do
    query = from(p in Product, where: p.taxon_id == ^taxon_id and p.is_active == true)

    review_query = from(c in Review, limit: 5, preload: [rating_option_vote: :rating_option])

    Repo.all(query)
    |> Repo.preload(
      reviews: review_query,
      variants: [:images, options: :option_type, theme: [:option_types]],
      theme: [:option_types],
      options: :option_type
    )
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

    review_query = from(c in Review, limit: 5, preload: [rating_option_vote: :rating_option])

    query
    |> paginate(page_number, size)
    |> Repo.all()
    |> Repo.preload(
      reviews: review_query,
      variants: [:images, options: :option_type, theme: [:option_types]],
      theme: [:option_types],
      options: :option_type
    )
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

  @doc """
  Develops the query based on the giver params. At least sorting the
  products in Ascending orders of their names is considered as priority.
  This supports the following api calling...
  - /products
  - /products/slug
  - /products?sort=Z-A
  - /products?sort=A-Z
  - /products?sort=date
  - /products?sort=A-Z&filter[name]=Hill's
  - /products?sort=A-Z&filter[name]=Hill's&page[limit]=2&page[offset]=2
  - /products?sort=A-Z&filter[name]=Hill's&page[limit]=2
  """

  def define_query(params) do
    query =
      case params["sort"] do
        "Z-A" ->
          order_by(Product, desc: :name)

        "date" ->
          order_by(Product, desc: :inserted_at)

        _ ->
          order_by(Product, asc: :name)
      end

    query =
      case params["filter"] do
        %{"name" => filter} ->
          from(p in query, where: ilike(p.name, ^"%#{filter}%"))

        _ ->
          query
      end
  end
end
