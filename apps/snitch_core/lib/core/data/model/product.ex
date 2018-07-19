defmodule Snitch.Data.Model.Product do
  @moduledoc """
  Product API
  """
  use Snitch.Data.Model

  import Ecto.Query
  alias Ecto.Multi
  alias Snitch.Data.Schema.{Product, Variation}
  alias Snitch.Repo
  alias Snitch.Tools.Helper.ImageUploader
  alias Snitch.Data.Schema.Image

  @doc """
  Returns all Products
  """
  @spec get_all() :: [Product.t()]
  def get_all do
    Repo.all(Product)
  end

  @spec get(map | non_neg_integer) :: Product.t() | nil
  def get(query_params) do
    QH.get(Product, query_params, Repo)
  end

  @doc """
  Get listtable product
  Return following product
  - Standalone product.(Product that do not have variants)
  - Parent product (Product that has variants)

  In short returns product excluding the variant products
  """
  @spec get_product_list() :: [Product.t()]
  def get_product_list() do
    child_product_ids = from(c in Variation, select: c.child_product_id) |> Repo.all()
    query = from(p in Product, where: p.is_active == true and p.id not in ^child_product_ids)
    Repo.all(query)
  end

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
    QH.update(Product, params, product, Repo)
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
    with %Product{} = product <- get(id),
         changeset <- Product.delete_changeset(product) do
      Repo.update(changeset)
    end
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
    |> Multi.run(:product, fn _ ->
      QH.update(Product, params, product, Repo)
    end)
    |> Multi.run(:store_image, fn %{product: product} ->
      store_images(product, params)
    end)
    |> persist()
  end

  @doc """
  Returns the url of the location where image is stored.

  Takes as input `name` of the image and the `Product.t()`
  struct.
  """
  @spec image_url(String.t(), Product.t()) :: String.t()
  def image_url(name, product) do
    ImageUploader.url({name, product})
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
    |> persist()
  end

  def get_selling_prices(product_ids) do
    query = from(p in Product, select: {p.id, p.selling_price}, where: p.id in ^product_ids)

    query
    |> Repo.all()
    |> Enum.reduce(%{}, fn {v_id, sp}, acc ->
      Map.put(acc, v_id, sp)
    end)
  end

  @doc """
  Returns a a query.

  The query on execution generates a list
  of products from the supplied `product_ids`.
  """
  @spec get_by_id_list([non_neg_integer]) :: [Product.t()]
  def get_by_id_list(product_ids) do
    from(
      product in Product,
      where: product.id in ^product_ids,
      select: product
    )
  end

  ####################### Private Functions ########################

  defp persist(multi) do
    case Repo.transaction(multi) do
      {:ok, _} ->
        {:ok, "success"}

      {:error, _, failed_value, _} ->
        {:error, failed_value}
    end
  end

  defp store_images(product, params) do
    uploads = params["images"]

    uploads =
      Enum.map(uploads, fn
        %{"image" => %Plug.Upload{} = upload} ->
          ImageUploader.store({upload, product})

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
        nil ->
          {:error, "image not found"}

        image ->
          {:ok, image}
      end
    end)
  end

  defp get_product(multi, product_id) do
    Multi.run(multi, :product, fn _ ->
      case get(product_id) do
        nil ->
          {:error, "prodcut not found"}

        product ->
          {:ok, product}
      end
    end)
  end

  defp remove_image_from_store(multi) do
    Multi.run(multi, :remove_from_upload, fn %{image: image, product: product} ->
      case ImageUploader.delete({image.name, product}) do
        :ok ->
          {:ok, "success"}

        _ ->
          {:error, "not found"}
      end
    end)
  end
end
