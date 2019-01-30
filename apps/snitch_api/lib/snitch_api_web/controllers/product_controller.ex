defmodule SnitchApiWeb.ProductController do
  use SnitchApiWeb, :controller

  alias Snitch.Data.Model.{Product, ProductReview}
  alias Snitch.Core.Tools.MultiTenancy.Repo
  alias SnitchApi.ProductsContext, as: Context
  alias SnitchApiWeb.Elasticsearch.Product.ListView, as: ESPListView
  alias SnitchApiWeb.Elasticsearch.Product.SuggestView, as: ESPSuggestView
  alias Snitch.Tools.Cache

  plug(SnitchApiWeb.Plug.DataToAttributes)
  action_fallback(SnitchApiWeb.FallbackController)

  def reviews(conn, %{"id" => id}) do
    with {:ok, product} <- Product.get(id) do
      reviews =
        product
        |> Repo.preload(reviews: [rating_option_vote: :rating_option])
        |> Map.take([:reviews])

      render(
        conn,
        SnitchApiWeb.ReviewView,
        "index.json-api",
        data: reviews.reviews
      )
    end
  end

  def rating_summary(conn, %{"id" => id}) do
    id = String.to_integer(id)

    with {:ok, product} <- Product.get(id) do
      rating_data = ProductReview.review_aggregate(product)
      render(conn, "rating_summary.json-api", data: rating_data, id: id)
    end
  end

  @include ~s(reviews,reviews.rating_option_vote, variants,variants.images,
  variants.options,variants.options.option_type,options,options.option_type,
  theme,theme.option_types,reviews.rating_option_vote.rating_option)
  def index(conn, params) do
    {products, page, aggregations, total} =
      Cache.get(
        conn.host <> conn.request_path <> conn.query_string,
        {
          fn conn, params -> Context.list_products(conn, params) end,
          [conn, params]
        },
        :timer.minutes(15)
      )

    json(
      conn,
      JaSerializer.format(ESPListView, products, conn,
        page: page,
        meta: %{
          "aggregations" => aggregations,
          "total" => total,
          "appliedParams" => params
        }
      )
    )
  end

  def show(conn, %{"product_slug" => slug} = params) do
    case Context.product_by_slug(slug) do
      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> render(SnitchApiWeb.ErrorView, :"404")

      {:ok, product} ->
        render(
          conn,
          "show.json-api",
          data: product,
          opts: [include: @include]
        )
    end
  end

  def suggest(conn, %{"q" => term}) do
    suggestions =
      Cache.get(
        conn.host <> conn.request_path <> conn.query_string,
        {
          fn term -> Context.suggest(term) end,
          [term]
        },
        :timer.minutes(15)
      )

    json(
      conn,
      JaSerializer.format(ESPSuggestView, suggestions, conn)
    )
  end

  def suggest(conn, _), do: suggest(conn, %{"q" => ""})
end
