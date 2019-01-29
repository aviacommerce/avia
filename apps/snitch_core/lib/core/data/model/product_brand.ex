defmodule Snitch.Data.Model.ProductBrand do
  @moduledoc """
  Product Brand API
  """
  use Snitch.Data.Model
  alias Ecto.Multi
  alias Snitch.Data.Schema.{Image, ProductBrand}
  alias Snitch.Data.Model.Image, as: ImageModel
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
    ImageModel.create(ProductBrand, params, "brand_image")
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
    ImageModel.update(ProductBrand, model, params, "brand_image")
  end

  def update(model, params) do
    QH.update(ProductBrand, params, model, Repo)
  end

  @doc """
  Returns an Product Brand.

  Takes Product Brand id as input.
  """
  @spec get(integer) :: {:ok, ProductBrand.t()} | {:error, atom}
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
    with {:ok, %ProductBrand{} = brand_struct} <- get(id),
         brand <- brand_struct |> Repo.preload(:image),
         changeset <- ProductBrand.delete_changeset(brand, %{}) do
      delete_product_brand(brand, brand.image, changeset)
    else
      {:error, msg} -> {:error, msg}
    end
  end

  defp delete_product_brand(_brand, nil, changeset) do
    Repo.delete(changeset)
  end

  defp delete_product_brand(brand, image, changeset) do
    ImageModel.delete(brand, image, changeset)
  end
end
