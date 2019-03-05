defmodule Snitch.Data.Model.Product do
  @moduledoc """
  Product API
  """
  use Snitch.Data.Model
  use Rummage.Ecto

  import Ecto.Query
  alias Ecto.Multi
  alias Snitch.Tools.GenNanoid
  alias Snitch.Data.Model.Image, as: ImageModel
  alias Snitch.Data.Schema.{Image, Product, Variation, Taxon}
  alias Snitch.Tools.Helper.ImageUploader
  alias Snitch.Core.Tools.MultiTenancy.Repo
  alias Snitch.Tools.ElasticSearch.Product.Store, as: ESProductStore

  @product_states [:active, :in_active, :draft]

  @doc """
  Returns all Products
  """
  @spec get_all() :: [Product.t()]
  def get_all do
    Repo.all(Product)
  end

  @doc """
  Returns all Products with the given list of entities preloaded
  """
  @spec get_all_with_preloads(list) :: [Product.t()]
  def get_all_with_preloads(preloads) do
    try do
      Repo.all(Product) |> Repo.preload(preloads)
    rescue
      e in ArgumentError -> nil
    end
  end

  @doc """
  Returns all Products with the given parameters.
  """
  @spec get(map | non_neg_integer) :: {:ok, Product.t()} | {:error, atom}
  def get(query_params) do
    case QH.get(Product, query_params, Repo) do
      {:error, msg} ->
        {:error, msg}

      {:ok, product} ->
        product = preload_with_variants_in_state(product)
        {:ok, product}
    end
  end

  @spec get_product_list() :: [Product.t()]
  def get_product_list() do
    Repo.all(admin_display_product_query())
  end

  @doc """
  Updates the default image for a given product
  from the given list of images.
  """
  def update_default_image(%{images: images}, default_image) do
    Enum.map(images, &ImageModel.update(%{is_default: to_string(&1.id) == default_image}, &1))
  end

  @doc """
  Get listtable product
  Return following product
  - Standalone product.(Product that do not have variants)
  - Parent product (Product that has variants)
  In short returns product excluding the variant products
  """
  def admin_display_product_query() do
    child_product_ids =
      Variation
      |> select([v], v.child_product_id)
      |> Repo.all()

    Product
    |> where([p], p.id not in ^child_product_ids)
  end

  def preload_with_variants_in_state(product, states \\ [:active, :in_active, :draft]) do
    product = Repo.preload(product, :variants)

    %{
      product
      | variants: Enum.filter(product.variants, fn variant -> variant.state in states end)
    }
  end

  defdelegate preload_non_deleted_variants(product),
    to: __MODULE__,
    as: :preload_with_variants_in_state

  @doc """
  Get listtable product
  Return following product
  - Standalone product.(Product that do not have variants)
  - Variant product (excluding their parent)
  In short returns product excluding the parent products
  """
  def sellable_products_query() do
    parent_product_ids =
      Variation
      |> distinct([v], v.parent_product_id)
      |> select([v], v.parent_product_id)
      |> Repo.all()

    Product
    |> join(:left, [p], v in Variation, v.child_product_id == p.id)
    |> where(
      [p, v],
      p.state == "active" and p.deleted_at == ^0 and p.id not in ^parent_product_ids
    )
  end

  @spec get_product_with_default_image(Product.t()) :: Product.t()
  def get_product_with_default_image(product) do
    product = Repo.preload(product, :images)

    %{
      product
      | images: Enum.filter(product.images, & &1.is_default)
    }
  end

  @spec get_rummage_product_list(any) :: Product.t()
  def get_rummage_product_list(rummage_opts) do
    opts =
      if rummage_opts do
        convert_to_atom_map(rummage_opts)
      else
        Map.new()
      end

    {query, _rummage} =
      from(p in admin_display_product_query())
      |> Map.put(:prefix, Repo.get_prefix())
      |> Rummage.Ecto.rummage(opts)

    query = from(p in query, preload: [:images, :variants])

    query
    |> Ecto.Queryable.to_query()
    |> Repo.all()
    |> Enum.map(&preload_non_deleted_variants/1)
  end

  defp convert_to_atom_map(map), do: to_atom_map("", map)

  defp to_atom_map(_key, map) when is_map(map),
    do: Map.new(map, fn {k, v} -> {String.to_atom(k), to_atom_map(k, v)} end)

  defp to_atom_map(k, v) when is_bitstring(v) and k == "search_term", do: v

  defp to_atom_map(_k, v) when is_bitstring(v), do: v |> String.to_atom()

  defp to_atom_map(_k, v), do: v

  @doc """
  Create a Product with supplied params
  """
  @spec create(map) :: {:ok, Product.t()} | {:error, Ecto.Changeset.t()}
  def create(params) do
    QH.create(Product, params, Repo)
  end

  @doc """
  Update a Product with supplied params
  """
  @spec update(Product.t(), map) :: {:ok, Product.t()} | {:error, Ecto.Changeset.t()}
  def update(product, params) do
    with {:ok, product} <- QH.update(Product, params, product, Repo) do
      ESProductStore.update_product_to_es(product)
      {:ok, product}
    else
      {:error, error} -> {:error, error}
    end
  end

  @doc """
  Returns an Product
  Takes Product id as input
  """
  @spec get(integer) :: Product.t() | nil
  def get(id) do
    QH.get(Product, id, Repo)
  end

  @doc """
  Discontinues a product
  Takes Product id as input
  """
  @spec get(integer) :: {:ok, Product.t()} | {:error, Ecto.Changeset.t()} | nil
  def delete(id) do
    with {:ok, %Product{} = product} <- get(id),
         _ <- ESProductStore.update_product_to_es(product, :delete),
         changeset <- Product.delete_changeset(product) do
      product = product |> Repo.preload(:images)
      Enum.map(product.images, &delete_image(product.id, &1.id))
      Repo.update(changeset)
    end
  end

  @doc """
  Deletes all product that fall under a particular category and all its children
  category
  """
  @spec delete_by_category(Taxon.t()) :: {:ok, [Products.t()]} | {:error, :delete_failed}
  def delete_by_category(%Taxon{} = taxon) do
    with product_by_category_query <- Product.product_by_category_query(taxon.id),
         product_delete_query <- Product.set_delete_fields(product_by_category_query) do
      total_products =
        from(p in product_by_category_query, select: count(p.id))
        |> Repo.one()

      {delete_product_count, products_ids} =
        Repo.update_all(product_delete_query, [], returning: [:id])

      if(total_products == delete_product_count) do
        {:ok, products_ids}
      else
        {:error, :delete_failed}
      end
    end
  end

  @doc """
  Gets all product under a particular product category.

  All category tree is considered under the category the search is done.
  """
  @spec get_products_by_category(integer) :: [Product.t()]
  def get_products_by_category(taxon_id) do
    taxon_id
    |> Product.product_by_category_query()
    |> Repo.all()
  end

  @doc """
  Handles creating new images and associating them with the product.
  The function stores the name of the image in the `snitch_images` table
  and stores the image file at a location specified in `Arc` Configuartion.
  #### See
  `Snitch.Tools.Helper.ImageUploader`
  The functions expects a `Product.t()` struct and a `params` map.
  To add new images the `params` map expects a list of images as a `%Plug.Upload{}`
  struct under the "images" key.
  ```
  %{"images" => [
      "image" => %Plug.Upload{},
      "image" => %Plug.UPload{}
  ]}
  ```
  ## Caution!
  In case some images are added to the product and you wish to retain them then
  they need to be passed in the map in the following format.
  The images if not included would be deleted and would lead to inconsistencies.
  ```
    %{"images" => [
      "image" => %Plug.Upload{},
      %{id: 1, name: "abc.png"}
  ]}
  ```
  In case you want to delete the images associated with the product,
  consider using the `delete_image/2` method.
  ## TODO
  Handle return properly for `product`.
  """
  @spec add_images(Product.t(), map) :: {:ok, map} | {:error, any()}
  def add_images(product, params) do
    Multi.new()
    |> Multi.run(:struct, fn _ ->
      QH.update(Product, params, product, Repo)
    end)
    |> Multi.run(:store_image, fn %{struct: product} ->
      store_images(product, params)
    end)
    |> ImageModel.persist()
  end

  @doc """
  Delete an image associated with a product.
  Takes as input id of the `image` to be deleted and the `product` id.
  Removes the image from the "snitch_images" table and removes the association
  between the product and the image from the assocation table.
  Also, removes the image file from the location where it is stored.
  """
  @spec delete_image(non_neg_integer(), non_neg_integer()) :: {:ok, map} | {:error, any()}
  def delete_image(product_id, image_id) do
    query =
      from(
        assoc in "snitch_product_images",
        where: assoc.product_id == ^product_id and assoc.image_id == ^image_id
      )

    Multi.new()
    |> get_product(product_id)
    |> get_image(image_id)
    |> Multi.run(:delete_image, fn _ ->
      QH.delete(Image, image_id, Repo)
    end)
    |> Multi.delete_all(:delete, query)
    |> remove_image_from_store()
    |> ImageModel.persist()
  end

  ####################### Private Functions ########################

  defp store_images(product, params) do
    uploads = params["images"]

    uploads =
      Enum.map(uploads, fn
        %{"image" => %{filename: name, path: path, url: url, type: type} = upload} ->
          upload = %Plug.Upload{filename: name, path: path, content_type: type}
          product = %{product | tenant: Repo.get_prefix()}
          ImageModel.store(upload, product)

        _ ->
          {:ok, "success"}
      end)

    if Enum.any?(uploads, fn upload ->
         case upload do
           {:error, _} -> true
           _ -> false
         end
       end) do
      {:error, "upload error"}
    else
      {:ok, "upload success"}
    end
  end

  defp get_image(multi, image_id) do
    Multi.run(multi, :image, fn _ ->
      case QH.get(Image, image_id, Repo) do
        {:error, _} ->
          {:error, "image not found"}

        {:ok, image} ->
          {:ok, image}
      end
    end)
  end

  defp get_product(multi, product_id) do
    Multi.run(multi, :product, fn _ ->
      case get(product_id) do
        {:error, _} ->
          {:error, "product not found"}

        {:ok, product} ->
          {:ok, product}
      end
    end)
  end

  defp remove_image_from_store(multi) do
    Multi.run(multi, :remove_from_upload, fn %{image: image, product: product} ->
      case ImageModel.delete_image(image.name, product) do
        :ok ->
          {:ok, "success"}

        _ ->
          {:error, "not found"}
      end
    end)
  end

  # TODO This needs to be replaced and we need a better system to identify
  # the type of product.
  @spec is_parent_product(String.t()) :: true | false
  def is_parent_product(product_id) when is_binary(product_id) do
    status =
      Product
      |> Repo.get(product_id)
      |> Repo.preload(:parent_variation)
      |> is_parent_or_child()

    case status do
      :parent ->
        true

      _ ->
        false
    end
  end

  @spec is_child_product(Product.t()) :: true | false
  def is_child_product(product) do
    status = product |> Repo.preload(:parent_variation) |> is_parent_or_child()

    case status do
      :child ->
        true

      _ ->
        false
    end
  end

  def is_parent_or_child(%{parent_variation: nil}), do: :parent
  def is_parent_or_child(%{parent_variation: %{parent_product: _}}), do: :child

  @spec get_selling_prices(List.t()) :: Map.t()
  def get_selling_prices(product_ids) do
    query = from(p in Product, select: {p.id, p.selling_price}, where: p.id in ^product_ids)

    query
    |> Repo.all()
    |> Enum.reduce(%{}, fn {v_id, sp}, acc ->
      Map.put(acc, v_id, sp)
    end)
  end

  @doc """
  Returns the product that has the inventory tracking set on it.
  """
  @spec product_with_inventory_tracking(Product.t()) :: Product.t()
  def product_with_inventory_tracking(product) do
    case is_child_product(product) do
      true ->
        product = Repo.preload(product, parent_variation: :parent_product)
        product.parent_variation.parent_product

      false ->
        product
    end
  end

  @doc """
  Ordering of product depends on many things, for now we just check
  sufficient stock is available based on the inventory tracking set on the product.

  Following is the behaviour based on inventory tracking:

  `none`

  When we don't track product, it is always orderable

  `product`

  When tracking inventory by product, we only check the stock for product itself
  without consideration of variant products.

  `variant`

  When tracking inventory by variant, parent product is not orderable. Variant
  product are orderable if sufficient stock is available.
  """
  @spec is_orderable?(Product.t()) :: true | false
  def is_orderable?(product) do
    with product_with_tracking <- product_with_inventory_tracking(product) do
      case product_with_tracking.inventory_tracking do
        :none ->
          true

        :product ->
          case is_child_product(product) do
            true ->
              has_stock?(product_with_tracking)

            false ->
              has_stock?(product)
          end

        :variant ->
          has_stock?(product)
      end
    end
  end

  defp has_stock?(product) do
    product = Repo.preload(product, :stock_items)

    case product.stock_items do
      [] ->
        false

      stock ->
        total_count_on_hand(stock) > 0
    end
  end

  defp total_count_on_hand(stocks) do
    Enum.reduce(stocks, 0, fn stock, acc -> stock.count_on_hand + acc end)
  end

  def get_product_count_by_state() do
    child_product_ids =
      Variation
      |> select([v], v.child_product_id)
      |> Repo.all()

    Product
    |> where(
      [p],
      p.state in ^@product_states and p.id not in ^child_product_ids
    )
    |> group_by([p], p.state)
    |> select([p], %{state: p.state, count: count(p.id)})
    |> Repo.all()
  end

  @doc """
  Checks if a product has variants or not
  """
  @spec has_variants?(Product.t()) :: true | false
  def has_variants?(product) do
    product = preload_with_variants_in_state(product)
    length(product.variants) > 0
  end

  @doc """
  Checks if a product tracks inventory by variant tracking
  """
  @spec is_variant_tracking_enabled?(Product.t()) :: true | false
  def is_variant_tracking_enabled?(product) do
    Product.is_variant_tracking_enabled?(product)
  end

  def generate_upi() do
    upi = "A#{GenNanoid.gen_nano_id()}C"

    case get_upi_if_unique(upi) do
      {:error, _} ->
        generate_upi()

      {:ok, upi} ->
        upi
    end
  end

  # TODO: write test case for this
  def get_upi_if_unique(upi) do
    case get_product_with_upi(upi) do
      nil ->
        {:ok, upi}

      _ ->
        {:error, "not_unique"}
    end
  end

  defp get_product_with_upi(upi) do
    from(p in "snitch_products", select: p.upi, where: p.upi == ^upi) |> Repo.one()
  end

  @doc """
  Returns the `parent product` of the supplied `variant`.

  In case supplied product is not a variant, returns nil.
  """
  @spec get_parent_product(Product.t()) :: Product.t() | nil
  def get_parent_product(product) do
    product = Repo.preload(product, parent_variation: :parent_product)
    if product.parent_variation, do: product.parent_variation.parent_product, else: nil
  end

  @doc """
  Returns `tax_class_id` of the product.

  Since tax class is set only for parent and not variants, if the
  supplied product is a variant, tax class of the parent product is
  returned.
  """
  @spec get_tax_class_id(Product.t()) :: non_neg_integer
  def get_tax_class_id(product) do
    tax_class_id(product, product.tax_class_id)
  end

  defp tax_class_id(product, nil) do
    product = get_parent_product(product)
    product.tax_class_id
  end

  defp tax_class_id(_product, tax_class_id), do: tax_class_id
end
