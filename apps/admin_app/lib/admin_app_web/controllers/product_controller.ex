defmodule AdminAppWeb.ProductController do
  use AdminAppWeb, :controller

  alias Snitch.Repo
  alias Snitch.Data.Model.Product, as: ProductModel
  alias Snitch.Data.Schema.Product, as: ProductSchema
  alias Snitch.Data.Model.ProductPrototype, as: PrototypeModel
  alias Snitch.Data.Schema.ProductBrand

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
    preloads = [variants: [options: :option_type]]

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

  def generate_variant_params(parent_product, options) do
    t =
      options
      |> Map.to_list()
      |> Enum.map(fn {index, map} ->
        map["value"]
        |> String.trim()
        |> String.split(",")
        |> Enum.map(fn v ->
          %{option_type_id: map["option_type_id"], value: v}
        end)
      end)

    generate_option_combinations(t, [])
    |> Enum.map(fn o ->
      %{
        "child_product" => %{
          name: product_name_from_options(parent_product, o),
          options: o
        }
      }
    end)
  end

  defp product_name_from_options(product, options) do
    options
    |> Enum.reduce(product.name, fn x, acc -> "#{acc} #{x.value}" end)
  end

  def generate_option_combinations([h | tail], []) do
    acc =
      h
      |> Enum.map(&[&1])

    generate_option_combinations(tail, acc)
  end

  def generate_option_combinations([], acc) do
    acc
  end

  def generate_option_combinations([h | tail], acc) do
    result =
      acc
      |> Enum.flat_map(fn v ->
        h
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

    conn
    |> assign(:prototype, prototype)
    |> assign(:brands, brands)
  end
end
