defmodule Snitch.Data.Model.ProductProperty do
  @moduledoc """
  ProductProperty API
  """
  use Snitch.Data.Model

  alias Snitch.Data.Schema.ProductProperty

  @doc """
  Returns all ProductProperty
  """
  @spec get_all() :: [ProductProperty.t()]
  def get_all do
    Repo.all(ProductProperty)
  end

  @doc """
  Returns all ProductProperty
  """
  @spec get_all() :: [ProductProperty.t()]
  def get_all_by_product(product_id) do
    ProductProperty
    |> where([pp], pp.product_id == ^product_id)
    |> Repo.all()
  end

  @doc """
  Returns all ProductProperty
  """
  @spec get_all() :: [ProductProperty.t()]
  def get_all_by_property(property_id) do
    ProductProperty
    |> where([pp], pp.property_id == ^property_id)
    |> Repo.all()
  end

  @doc """
  Create a ProductProperty with supplied params
  """
  @spec create(map) :: {:ok, ProductProperty.t()} | {:error, Ecto.Changeset.t()}
  def create(params) do
    QH.create(ProductProperty, params, Repo)
  end

  @doc """
  Update the ProductProperty with supplied params and ProductProperty instance
  """
  @spec update(ProductProperty.t(), map) ::
          {:ok, ProductProperty.t()} | {:error, Ecto.Changeset.t()}
  def update(model, params) do
    QH.update(ProductProperty, params, model, Repo)
  end

  @doc """
  Returns an ProductProperty

  Takes ProductProperty id as input
  """
  @spec get(integer) :: {:ok, ProductProperty.t()} | {:error, atom}
  def get(id) do
    QH.get(ProductProperty, id, Repo)
  end

  @spec get(map | non_neg_integer) :: {:ok, ProductProperty.t()} | {:error, atom}
  def get_by(query_fields_or_primary_key) do
    QH.get(ProductProperty, query_fields_or_primary_key, Repo)
  end

  @doc """
  Deletes the ProductProperty
  """
  @spec delete(non_neg_integer() | ProductProperty.t()) ::
          {:ok, ProductProperty.t()} | {:error, Ecto.Changeset.t()} | {:error, :not_found}
  def delete(id) when is_integer(id) do
    QH.delete(ProductProperty, id, Repo)
  end

  def delete(instance) do
    QH.delete(ProductProperty, instance, Repo)
  end
end
