defmodule Snitch.Data.Model.Product do
  @moduledoc """
  Product API.
  """

  use Snitch.Data.Model
  alias Snitch.Data.Schema.Product

  @doc """
  Gives the total count of products
  """
  @spec count() :: integer()
  def count() do
    query = from(p in Product, select: count(p.id))
    Repo.all(query)
  end

  @doc """
  Gives the total products in the given order. Have to pass a string og values `asc` or `desc`, by default it is `asc`.
  """
  @spec fetch_sorted_products(String.t()) :: Product.t()
  def fetch_sorted_products(sort \\ "asc") do
    case sort do
      "asc" ->
        Repo.all(from(p in Product, order_by: [asc: p.name]))
        |> Repo.preload(variants: [:images])

      "desc" ->
        Repo.all(from(p in Product, order_by: [desc: p.name]))
        |> Repo.preload(variants: [:images])

      _ ->
        :invalid_sort_value
    end
  end
end
