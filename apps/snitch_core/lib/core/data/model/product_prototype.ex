defmodule Snitch.Data.Model.ProductPrototype do
  @moduledoc """
  Product Prototype API
  """
  use Snitch.Data.Model

  alias Snitch.Data.Schema.ProductPrototype

  @doc """
  Returns all Product Prototype
  """
  @spec get_all() :: [ProductPrototype.t()]
  def get_all do
    Repo.all(ProductPrototype)
  end

  @doc """
  Create a Product Prototype with supplied params
  """
  @spec create(map) :: {:ok, ProductPrototype.t()} | {:error, Ecto.Changeset.t()}
  def create(params) do
    QH.create(ProductPrototype, params, Repo)
  end

  @doc """
  Returns a Product Prototype

  Takes Product Prototype id as input
  """
  @spec get(integer) :: {:ok, ProductPrototype.t()} | {:error, atom}
  def get(id) do
    QH.get(ProductPrototype, id, Repo)
  end

  @doc """
  Update the Product Prototype with supplied params and Prototype instance
  """
  @spec update(ProductPrototype.t(), map) ::
          {:ok, ProductPrototype.t()} | {:error, Ecto.Changeset.t()}
  def update(model, params) do
    QH.update(ProductPrototype, params, model, Repo)
  end

  @doc """
  Deletes the Product Prototype
  """
  @spec delete(non_neg_integer | struct() | binary) ::
          {:ok, ProductPrototype.t()} | {:error, Ecto.Changeset.t()} | {:error, :not_found}
  def delete(id) when is_integer(id) or is_binary(id) do
    QH.delete(ProductPrototype, id, Repo)
  end

  def delete(%ProductPrototype{} = instance) do
    QH.delete(ProductPrototype, instance, Repo)
  end
end
