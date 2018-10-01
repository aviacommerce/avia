defmodule AdminAppWeb.ProductController do
  use AdminAppWeb, :controller

  alias Snitch.Core.Tools.MultiTenancy.Repo
  alias Snitch.Data.Model.Product, as: ProductModel
  alias Snitch.Data.Model
  alias Snitch.Data.Schema.Product, as: ProductSchema
  alias Snitch.Data.Model.ProductPrototype, as: PrototypeModel

  alias Snitch.Data.Schema.{
    ProductBrand,
    StockLocation,
    VariationTheme,
    ProductProperty,
    Property
  }

  alias Snitch.Tools.Money
  alias Snitch.Data.Model.StockItem, as: StockModel
  alias Snitch.Data.Schema.StockItem, as: StockSchema

  plug(:load_resources when action in [:new, :edit])

  @rummage_default %{
    "rummage" => %{
      "search" => %{
        "state" => %{"search_expr" => "where", "search_term" => "active", "search_type" => "eq"}
      },
      "sort" => %{"field" => "name", "order" => "asc"}
    }
  }

  def index(conn, params) do
    if params["rummage"] do
      products =
        ProductModel.get_rummage_product_list(params["rummage"])
        |> Repo.preload([:images, [variants: :images]])

      render(conn, "index.html", products: products)
    else
      redirect_with_updated_conn(conn, @rummage_default)
    end
  end

  def new(conn, _params) do
    changeset = ProductSchema.create_changeset(%ProductSchema{}, %{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"product" => params}) do
    with {:ok, product} <- ProductModel.create(params) do
      redirect(conn, to: product_path(conn, :edit, product.id))
    else
      {:error, changeset} ->
        render(conn, "new.html", changeset: %{changeset | action: :new})
    end
  end

  def edit(conn, %{"id" => id} = params) do
    preloads = [variants: [options: :option_type], images: [], taxon: [:variation_themes]]

    with %ProductSchema{} = product <- ProductModel.get(id) |> Repo.preload(preloads) do
      changeset = ProductSchema.create_changeset(product, params)
      render(conn, "edit.html", changeset: changeset, parent_product: product)
    end
  end

  def update(conn, %{"product" => params}) do
    with %ProductSchema{} = product <- ProductModel.get(params["id"]),
         {:ok, _product} <- ProductModel.update(product, params) do
      redirect_with_updated_conn(conn, params)
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

  def delete(conn, %{"id" => id}) do
    with {:ok, _product} <- ProductModel.delete(id) do
      conn
      |> put_flash(:info, "Product deleted successfully")
      |> redirect(to: product_path(conn, :index))
    end
  end

  def new_variant(conn, params) do
    with %ProductSchema{} = parent_product <- ProductModel.get(params["product_id"]),
         variant_params <- generate_variant_params(parent_product, params["options"]),
         %Ecto.Changeset{valid?: true} = changeset <-
           ProductSchema.variant_create_changeset(parent_product, %{
             "variations" => variant_params,
             "theme_id" => params["theme_id"]
           }) do
      {:ok, _product} = Repo.update(changeset)
      redirect(conn, to: product_path(conn, :index))
    else
      _ ->
        conn
        |> put_flash(:error, "Failed to create variant")
        |> redirect(to: product_path(conn, :index))
    end
  end

  def select_category(conn, _params) do
    render(conn, "product_category.html")
  end

  def add_stock(conn, %{"stock" => params}) do
    with {:ok, stock} <- check_stock(params["product_id"], params["location_id"]),
         {:ok, _updated_stock} <- StockModel.update(params, stock) do
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
      |> Enum.map(fn {_index, map} ->
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
          max_retail_price: parent_product.max_retail_price,
          taxon_id: parent_product.taxon_id,
          shipping_category_id: parent_product.shipping_category_id
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

  defp load(conn, _params) do
    themes = Repo.all(VariationTheme)

    brands = Repo.all(ProductBrand)

    stock_locations = Repo.all(StockLocation)

    conn
    |> assign(:themes, themes)
    |> assign(:stock_locations, stock_locations)
    |> assign(:brands, brands)

    # |> assign(:prototype, prototype)
  end

  defp redirect_with_updated_conn(conn, params) do
    updated_conn =
      conn
      |> Map.put(:query_params, params)
      |> Map.put(:query_string, Plug.Conn.Query.encode(params))

    redirect(updated_conn, to: product_path(updated_conn, :index, params))
  end

  def index_property(conn, _params) do
    render(conn, "property_index.html")
  end

  def new_property(conn, params) do
    changeset =
      ProductProperty.create_changeset(%ProductProperty{}, %{product_id: params["product_id"]})

    render(conn, "property_new.html",
      conn: conn,
      changeset: changeset,
      product_id: params["product_id"]
    )
  end

  def create_property(conn, params) do
    with %ProductSchema{} = _product <- ProductModel.get(params["product_id"]),
         %Property{} = _property <- Model.Property.get(params["product_property"]["property_id"]),
         {:ok, _product_property} <- Model.ProductProperty.create(params["product_property"]) do
      redirect(conn, to: product_path(conn, :edit, params["product_id"]))
    else
      {:error, changeset} ->
        render(conn, "property_new.html", changeset: changeset)
    end
  end

  def edit_property(conn, params) do
    changeset = ProductProperty.update_changeset(%ProductProperty{}, params)
    render(conn, "property_edit.html", changeset: changeset, conn: conn)
  end

  def update_property(conn, params) do
    with %ProductProperty{} = product_property <-
           Model.ProductProperty.get_by(%{
             product_id: params["product_property"]["product_id"],
             property_id: params["product_property"]["property_id"]
           }),
         {:ok, _} = Model.ProductProperty.update(product_property, params["product_property"]) do
      redirect(conn, to: product_path(conn, :edit, params["product_property"]["product_id"]))
    else
      {:error, changeset} ->
        render(conn, "property_edit.html", changeset: changeset, conn: conn)
    end
  end

  def delete_property(conn, params) do
    with %ProductProperty{} = product_property <-
           Model.ProductProperty.get_by(%{
             product_id: params["product_id"],
             property_id: params["property_id"]
           }),
         {:ok, _} <- Model.ProductProperty.delete(product_property) do
      conn
      |> put_flash(:info, "Product property deleted successfully")

      redirect(conn, to: product_path(conn, :edit, params["product_id"]))
    end
  end
end
