defmodule SnitchApiWeb.ProductView do
  use SnitchApiWeb, :view
  use JaSerializer.PhoenixView
  alias Snitch.Data.Schema.Image
  alias Snitch.Data.Schema.Product, as: ProductSchema
  alias Snitch.Data.Model.{Product, ProductReview}
  alias Snitch.Core.Tools.MultiTenancy.Repo
  import Ecto.Query

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
    :is_orderable,
    :display_price,
    :default_image
  ])

  def selling_price(product) do
    Money.round(product.selling_price, currency_digits: :cash)
  end

  def max_retail_price(product) do
    Money.round(product.max_retail_price, currency_digits: :cash)
  end

  def display_price(product) do
    product.selling_price |> to_string
  end

  def default_image(product, _conn) do
    default_image = from(image in Image, where: image.is_default == true)

    query =
      from(p in ProductSchema, where: p.id == ^product.id, preload: [images: ^default_image])

    product = Repo.one(query)
    image = product.images |> List.first()
    %{"default_product_url" => Product.image_url(image.name, product)}
  end

  def images(product, _conn) do
    product = product |> Repo.preload(:images)

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
