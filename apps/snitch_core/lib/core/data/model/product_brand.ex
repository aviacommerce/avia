defmodule Snitch.Data.Model.ProductBrand do
  @moduledoc """
  Product Brand API
  """
  use Snitch.Data.Model
  alias Ecto.Multi
  alias Snitch.Data.Schema.{Image, ProductBrand}
  alias Snitch.Tools.Helper.ImageUploader

  @doc """
  Returns all Product Brands
  """
  @spec get_all() :: [ProductBrand.t()]
  def get_all do
    Repo.all(ProductBrand)
  end

  @doc """
  Creates a `ProductBrand` with supplied params.

  If an `image` is also supplied in `params` then the image
  is associated with the product brand and is uploaded at
  location specified by the configuration.
  #### See
  `Snitch.Tools.Helper.ImageUploader`

  The image to be uploaded is expected as `%Plug.Upload{}`
  struct.
      params = %{name: "xyz",
                  image: %Plug.Upload{content_type: "image/png"}
                }

  The `association` between `product brand` and the `image` is through
  a middle table.
  #### See
  `Snitch.Data.Schema.ProductBrandImage`
  """
  @spec create(map) ::
          {:ok, ProductBrand.t()} | {:error, Ecto.Changeset.t()} | {:error, String.t()}
  def create(%{"image" => image} = params) do
    Multi.new()
    |> Multi.run(:image, fn _ ->
      QH.create(Image, params, Repo)
    end)
    |> Multi.run(:product_brand, fn %{image: image} ->
      params = Map.put(params, "brand_image", %{image_id: image.id})
      QH.create(ProductBrand, params, Repo)
    end)
    |> upload_image_multi(image)
    |> persist()
  end

  def create(params) do
    QH.create(ProductBrand, params, Repo)
  end

  @doc """
  Updates the ProductBrand` with the supplied params.

  If an `image` present in supplied `params` then the image associated earlier
  is removed from both the `image` table as well as the upload location and
  the association is removed.

  The new supplied image in the `params` is then associated with the product brand
  and is uploaded at the storage location. Look at the section in `create/1` for
  the configuration.
  """
  @spec update(ProductBrand.t(), map) :: {:ok, ProductBrand.t()} | {:error, Ecto.Changeset.t()}
  def update(model, %{"image" => image} = params) do
    old_image = model.image

    Multi.new()
    |> Multi.run(:image, fn _ ->
      QH.create(Image, params, Repo)
    end)
    |> Multi.run(:product_brand, fn %{image: image} ->
      params = Map.put(params, "brand_image", %{image_id: image.id})
      QH.update(ProductBrand, params, model, Repo)
    end)
    |> delete_image_multi(old_image, model)
    |> upload_image_multi(image)
    |> persist()
  end

  def update(model, params) do
    QH.update(ProductBrand, params, model, Repo)
  end

  @doc """
  Returns an Product Brand.

  Takes Product Brand id as input.
  """
  @spec get(integer) :: ProductBrand.t() | nil
  def get(id) do
    QH.get(ProductBrand, id, Repo)
  end

  @doc """
  Deletes the Product Brand.

  # Note
  Upon deletion any `image` associated with the product brand
  is removed from both the database table as well as the upload
  location.
  """
  @spec delete(non_neg_integer() | ProductBrand.t()) ::
          {:ok, ProductBrand.t()} | {:error, Ecto.Changeset.t()} | {:error, :not_found}
  def delete(id) do
    with %ProductBrand{} = brand <- get(id) |> Repo.preload(:image),
         changeset <- ProductBrand.delete_changeset(brand, %{}) do
      delete_product_brand(brand, brand.image, changeset)
    else
      nil -> {:error, :not_found}
    end
  end

  @doc """
  Returns the url of the location where image is stored.

  Takes as input `name` of the `image` and the `ProductBrand.t()`
  struct.
  """
  @spec image_url(String.t(), ProductBrand.t()) :: String.t()
  def image_url(name, product_brand) do
    ImageUploader.url({name, product_brand})
  end

  ########################### private functions #####################

  defp persist(multi) do
    case Repo.transaction(multi) do
      {:ok, _} ->
        {:ok, "success"}

      {:error, _, failed_value, _} ->
        {:error, failed_value}
    end
  end

  defp upload_image_multi(multi, %Plug.Upload{} = image) do
    Multi.run(multi, :image_upload, fn %{product_brand: product_brand} ->
      case ImageUploader.store({image, product_brand}) do
        {:ok, _} ->
          {:ok, "upload success"}

        _ ->
          {:error, "upload error"}
      end
    end)
  end

  defp delete_image_multi(multi, image, product_brand) do
    multi
    |> Multi.run(:remove_from_upload, fn _ ->
      case ImageUploader.delete({image.name, product_brand}) do
        :ok ->
          {:ok, "success"}

        _ ->
          {:error, "not_found"}
      end
    end)
    |> Multi.run(:delete_image, fn _ ->
      QH.delete(Image, image.id, Repo)
    end)
  end

  defp delete_product_brand(_brand, nil, changeset) do
    Repo.delete(changeset)
  end

  defp delete_product_brand(brand, image, changeset) do
    Multi.new()
    |> Multi.run(:delete_product_brand, fn _ ->
      Repo.delete(changeset)
    end)
    |> delete_image_multi(image, brand)
    |> persist()
  end
end
