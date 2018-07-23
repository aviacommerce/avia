defmodule Snitch.Data.Model.Product do
  @moduledoc """
  Product API
  """
  use Snitch.Data.Model

  alias Snitch.Data.Schema.Product

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
end
