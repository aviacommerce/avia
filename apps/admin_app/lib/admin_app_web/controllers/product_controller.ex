defmodule AdminAppWeb.ProductController do
  use AdminAppWeb, :controller

  alias Snitch.Repo
  alias Snitch.Data.Model.Product, as: ProductModel
  alias Snitch.Data.Schema.Product, as: ProductSchema
  alias Snitch.Data.Model.ProductPrototype, as: PrototypeModel
  alias Snitch.Data.Schema.{ProductBrand, StockLocation}
  alias Snitch.Tools.Money
  alias Snitch.Data.Model.StockItem, as: StockModel
  alias Snitch.Data.Schema.StockItem, as: StockSchema

  plug(:scrub_referer_query_params when action in [:create])
  plug(:load_resources when action in [:new, :edit])

  def index(conn, _params) do
    products =
      ProductModel.get_product_list()
      |> Repo.preload(variants: :images)

    render(conn, "index.html", products: products)
  end

  def new(conn, params) do
    changeset = ProductSchema.create_changeset(%ProductSchema{}, %{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"product" => params} = t) do
    with {:ok, product} <- ProductModel.create(params) do
      redirect(conn, to: product_path(conn, :index))
    else
      {:error, changeset} ->
        render(conn, "new.html", changeset: %{changeset | action: :new})
    end
  end

  def edit(conn, %{"id" => id} = params) do
    preloads = [variants: [options: :option_type], images: []]

    with %ProductSchema{} = product <- ProductModel.get(id) |> Repo.preload(preloads) do
      changeset = ProductSchema.create_changeset(product, params)
      render(conn, "edit.html", changeset: changeset, parent_product: product)
    end
  end

  def update(conn, %{"product" => params}) do
    with %ProductSchema{} = product <- ProductModel.get(params["id"]),
         {:ok, product} <- ProductModel.update(product, params) do
      redirect(conn, to: product_path(conn, :index))
    end
  end

  def add_images(conn, %{"product_images" => product_images, "product_id" => id}) do
    product =
      id
      |> String.to_integer()
      |> ProductModel.get()
      |> Repo.preload(:images)

    images = (product_images["images"] ++ product.images) |> parse_images()

    params = %{"images" => images}

    case ProductModel.add_images(product, params) do
      {:ok, _} ->
        redirect(conn, to: product_path(conn, :index))

      {:error, _} ->
        redirect(conn, to: product_path(conn, :index))
    end
  end

  def delete_image(conn, %{"image_id" => image_id, "product_id" => product_id}) do
    image_id = String.to_integer(image_id)
    product_id = String.to_integer(product_id)

    case ProductModel.delete_image(product_id, image_id) do
      {:ok, _} ->
        conn
        |> put_status(200)
        |> json(%{data: "success"})

      {:error, reason} ->
        conn
        |> put_status(500)
        |> json(%{data: reason})
    end
  end

  defp parse_images(image_list) do
    Enum.reduce(image_list, [], fn
      %Plug.Upload{} = image, acc ->
        [%{"image" => image} | acc]

      image, acc ->
        %{id: id, name: name} = Map.from_struct(image)
        [%{"id" => id, "name" => name} | acc]
    end)
  end

  def delete(conn, params) do
  end

  def new_variant(conn, params) do
    with %ProductSchema{} = parent_product <- ProductModel.get(params["product_id"]),
         variant_params <- generate_variant_params(parent_product, params["options"]) do
      changeset =
        ProductSchema.variant_create_changeset(parent_product, %{
          "variations" => variant_params,
          "theme_id" => params["theme_id"]
        })

      {:ok, product} = Repo.update(changeset)
      redirect(conn, to: product_path(conn, :index))
    end
  end

  def select_category(conn, params) do
    render(conn, "product_category.html")
  end

  def add_stock(conn, %{"stock" => params}) do
    with {:ok, stock} <- check_stock(params["product_id"], params["location_id"]),
         {:ok, updated_stock} <- StockModel.update(params, stock) do
      redirect(conn, to: product_path(conn, :index))
    end
  end

  defp check_stock(product_id, location_id) do
    query_fields = %{product_id: product_id, stock_location_id: location_id}

    case StockModel.get(query_fields) do
      %StockSchema{} = stock_item -> {:ok, stock_item}
      nil -> StockModel.create(product_id, location_id, 0, false)
    end
  end

  def generate_variant_params(parent_product, options) do
    options =
      options
      |> Map.to_list()
      |> Enum.map(fn {index, map} ->
        map["value"]
        |> String.trim()
        |> String.split(",")
        |> Enum.map(fn option_value ->
          %{option_type_id: map["option_type_id"], value: option_value}
        end)
      end)

    generate_option_combinations(options, [])
    |> Enum.map(fn options ->
      %{
        "child_product" => %{
          name: product_name_from_options(parent_product, options),
          options: options,
          selling_price: parent_product.selling_price,
          max_retail_price: parent_product.max_retail_price
        }
      }
    end)
  end

  defp product_name_from_options(product, options) do
    options
    |> Enum.reduce(product.name, fn x, acc -> "#{acc} #{x.value}" end)
  end

  def generate_option_combinations([head | tail], []) do
    acc =
      head
      |> Enum.map(&[&1])

    generate_option_combinations(tail, acc)
  end

  def generate_option_combinations([], acc) do
    acc
  end

  def generate_option_combinations([head | tail], acc) do
    result =
      acc
      |> Enum.flat_map(fn v ->
        head
        |> Enum.map(fn x -> v ++ [x] end)
      end)

    generate_option_combinations(tail, result)
  end

  def load_resources(conn, _opts) do
    load(conn, conn.params)
  end

  def scrub_referer_query_params(conn, _opts) do
    [{_, url} | tail] =
      conn.req_headers
      |> Enum.filter(fn {a, b} ->
        if a == "referer" do
          true
        else
          false
        end
      end)

    [_, query_params] = String.split(url, "?")
    params = URI.decode_query(query_params)
    load(conn, params)
  end

  defp load(conn, params) do
    prototype_id = params["prototype_id"]

    prototype =
      PrototypeModel.get(prototype_id)
      |> Repo.preload([:variation_themes])

    brands = Repo.all(ProductBrand)

    stock_locations = Repo.all(StockLocation)

    conn
    |> assign(:prototype, prototype)
    |> assign(:stock_locations, stock_locations)
    |> assign(:brands, brands)
  end
end
