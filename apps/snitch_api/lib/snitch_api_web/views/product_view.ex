defmodule SnitchApiWeb.ProductView do
  use SnitchApiWeb, :view
  use JaSerializer.PhoenixView
  alias Snitch.Data.Model.{Product, ProductReview}

  location("/products/:slug")

  attributes([
    :name,
    :description,
    :available_on,
    :deleted_at,
    :discontinue_on,
    :slug,
    :meta_description,
    :meta_keywords,
    :meta_title,
    :promotionable,
    :selling_price,
    :max_retail_price,
    :images,
    :rating_summary,
    :is_orderable
  ])

  def selling_price(product) do
    Money.round(product.selling_price, currency_digits: :cash)
  end

  def max_retail_price(product) do
    Money.round(product.max_retail_price, currency_digits: :cash)
  end

  def images(product, _conn) do
    product = product |> Snitch.Repo.preload(:images)

    product.images
    |> Enum.map(fn image -> %{"product_url" => Product.image_url(image.name, product)} end)
  end

  def rating_summary(product, _conn) do
    ProductReview.review_aggregate(product)
  end

  def is_orderable(product, _conn) do
    Product.is_orderable?(product)
  end

  has_one(
    :theme,
    serializer: SnitchApiWeb.VariationThemeView,
    include: false
  )

  has_many(
    :variants,
    serializer: SnitchApiWeb.ProductView,
    include: false
  )

  has_many(
    :options,
    serializer: SnitchApiWeb.ProductOptionValueView,
    include: false
  )

  has_many(
    :reviews,
    serializer: SnitchApiWeb.ReviewView,
    include: false
  )

  def render("rating_summary.json-api", %{data: data, id: id}) do
    %{
      links: %{
        self: "products/#{id}/rating-summary"
      },
      data: data
    }
  end
end
