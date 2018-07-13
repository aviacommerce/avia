defmodule Snitch.Data.Model.Product do
  @moduledoc """
  Product API
  """
  use Snitch.Data.Model

  alias Snitch.Data.Schema.{Product, Variation}
  import Ecto.Query

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
    query = from(p in Product, where: p.id not in ^child_product_ids)
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
end
