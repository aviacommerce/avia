defmodule Snitch.Data.Model.ProductBrand do
  @moduledoc """
  Product Brand API
  """
  use Snitch.Data.Model
  alias Snitch.Data.Schema.ProductBrand

  @doc """
  Returns all Product Brands
  """
  @spec get_all() :: [ProductBrand.t()]
  def get_all do
    Repo.all(ProductBrand)
  end

  @doc """
  Create a Product Brand with supplied params
  """
  @spec create(map) :: {:ok, ProductBrand.t()} | {:error, Ecto.Changeset.t()}
  def create(params) do
    QH.create(ProductBrand, params, Repo)
  end

  @doc """
  Update the Product Brand with supplied params and Brand instance
  """
  @spec update(ProductBrand.t(), map) :: {:ok, ProductBrand.t()} | {:error, Ecto.Changeset.t()}
  def update(model, params) do
    QH.update(ProductBrand, params, model, Repo)
  end

  @doc """
  Returns an Product Brand

  Takes Product Brand id as input
  """
  @spec get(integer) :: ProductBrand.t() | nil
  def get(id) do
    QH.get(ProductBrand, id, Repo)
  end

  @doc """
  Deletes the Product Brand
  """
  @spec delete(non_neg_integer() | ProductBrand.t()) ::
          {:ok, ProductBrand.t()} | {:error, Ecto.Changeset.t()} | {:error, :not_found}
  def delete(id) do
    with %ProductBrand{} = brand <- get(id),
         changeset <- ProductBrand.delete_changeset(brand, %{}) do
      Repo.delete(changeset)
    else
      nil -> {:error, :not_found}
    end
  end
end
