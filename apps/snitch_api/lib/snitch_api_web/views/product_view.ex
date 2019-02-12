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
    :upi,
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

  def name(product), do: append_option_value_in_name(product)

  defp append_option_value_in_name(%{options: options, name: name}) when is_list(options) do
    postfix =
      options
      |> Enum.map(&String.capitalize(&1.value))
      |> Enum.join(",")

    name <> " (" <> postfix <> ")"
  end

  defp append_option_value_in_name(%{name: name}), do: name

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
        image -> ImageModel.image_url(image.name, product, :thumb)
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
            get_images(images, product)
          else
            %{images: images, parent_product: parent_product} = get_parent_images(product)
            get_images(images, parent_product)
          end

        products ->
          get_images(product.images, product)
      end
  end

  defp get_images(images, product) do
    case images do
      [] ->
        [
          %{
            "small" => "",
            "thumb" => "",
            "large" => ""
          }
        ]

      images ->
        images
        |> Enum.map(fn image ->
          %{
            "small" => ImageModel.image_url(image.name, product, :small),
            "thumb" => ImageModel.image_url(image.name, product, :thumb),
            "large" => ImageModel.image_url(image.name, product, :large)
          }
        end)
    end
  end

  defp get_parent_images(product) do
    variant = Repo.get_by(Variation, child_product_id: product.id)

    case variant do
      nil ->
        %{images: [], parent_product: nil}

      _ ->
        parent_id = variant.parent_product_id
        parent_product = Repo.get_by(ProductSchema, id: parent_id) |> Repo.preload([:images])
        %{images: parent_product.images, parent_product: parent_product}
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
