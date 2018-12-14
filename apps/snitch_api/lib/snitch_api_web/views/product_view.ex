defmodule SnitchApiWeb.ProductView do
  use SnitchApiWeb, :view
  use JaSerializer.PhoenixView
  alias Snitch.Data.Schema.Image
  alias Snitch.Data.Schema.Variation
  alias Snitch.Data.Schema.Product, as: ProductSchema
  alias Snitch.Data.Model.ProductReview
  alias Snitch.Data.Model.Product
  alias Snitch.Data.Model.Image, as: ImageModel
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
    :default_image,
    :display_selling_price,
    :display_max_retail_price
  ])

  def selling_price(product) do
    Money.round(product.selling_price, currency_digits: :cash)
  end

  def max_retail_price(product) do
    Money.round(product.max_retail_price, currency_digits: :cash)
  end

  def display_max_retail_price(product) do
    product.max_retail_price |> to_string
  end

  def display_selling_price(product) do
    product.selling_price |> to_string
  end

  def default_image(product, _conn) do
    product = Product.get_product_with_default_image(product)

    url =
      case product.images |> List.first() do
        nil -> nil
        image -> ImageModel.image_url(image.name, product)
      end

    %{"default_product_url" => url}
  end

  def images(product, _conn) do
    product = product |> Repo.preload([:images, products: :products])

    product_images =
      case product.products do
        [] ->
          images = product.images

          if images != [] do
            images
          else
            get_parent_images(product)
          end

        products ->
          product.images
      end

    case product_images do
      [] ->
        [%{"product_url" => nil}]

      images ->
        images
        |> Enum.map(fn image -> %{"product_url" => ImageModel.image_url(image.name, product)} end)
    end
  end

  defp get_parent_images(product) do
    variant = Repo.get_by(Variation, child_product_id: product.id)

    case variant do
      nil ->
        []

      _ ->
        parent_id = variant.parent_product_id
        parent_product = Repo.get_by(ProductSchema, id: parent_id) |> Repo.preload([:images])
        parent_product.images
    end
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
