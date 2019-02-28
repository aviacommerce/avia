defmodule SnitchApi.ProductsContext do
  @moduledoc """
  The JSON-API context.
  """
  alias Snitch.Data.Model.Product, as: ProductModel
  alias Snitch.Core.Tools.MultiTenancy.Repo
  alias Snitch.Data.Schema.{Product, Review}
  alias Snitch.Tools.ElasticSearch.Product.Search, as: ProductSearch
  alias Snitch.Tools.ElasticSearch.Product.Suggestor, as: ProductSuggestor

  import Ecto.Query
  # @filter_allowables ~w(taxon_id brand_id)a
  # @partial_search_allowables ~w(name)a

  @doc """
  List out all the products
  """
  def list_products(conn, params) do
    ProductSearch.run(conn, params)
  end

  @doc """
  Gives the product with matched `slug` as {:ok, product} tuple or
  returns an {:error, :not_found} tuple if product is not found.
  """
  @spec product_by_slug(String.t()) :: map
  def product_by_slug(slug) do
    case ProductModel.get(%{slug: slug, deleted_at: 0}) do
      {:error, _} ->
        {:error, :not_found}

      {:ok, product} ->
        review_query = from(c in Review, limit: 5, preload: [rating_option_vote: :rating_option])

        product =
          product
          |> ProductModel.preload_with_variants_in_state([:active])
          |> Repo.preload(
            reviews: review_query,
            variants: [:images, options: :option_type, theme: [:option_types]],
            theme: [:option_types],
            options: :option_type
          )

        {:ok, product}
    end
  end

  def suggest(query) do
    ProductSuggestor.perform(query)
  end
end
