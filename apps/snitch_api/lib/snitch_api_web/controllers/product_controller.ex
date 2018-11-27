defmodule SnitchApiWeb.ProductController do
  use SnitchApiWeb, :controller

  alias Snitch.Data.Model.{Product, ProductReview}
  alias Snitch.Core.Tools.MultiTenancy.Repo
  alias SnitchApi.ProductsContext, as: Context

  plug(SnitchApiWeb.Plug.DataToAttributes)
  action_fallback(SnitchApiWeb.FallbackController)

  def reviews(conn, %{"id" => id}) do
    with product when not is_nil(product) <- Product.get(id) do
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

    with product when not is_nil(product) <- Product.get(id) do
      rating_data = ProductReview.review_aggregate(product)
      render(conn, "rating_summary.json-api", data: rating_data, id: id)
    end
  end

  @include ~s(reviews,reviews.rating_option_vote, variants,variants.images,
  variants.options,variants.options.option_type,options,options.option_type,
  theme,theme.option_types,reviews.rating_option_vote.rating_option)
  def index(conn, params) do
    {products, page} = Context.list_products(conn, params)

    render(
      conn,
      "index.json-api",
      data: products,
      opts: [page: page]
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
end
