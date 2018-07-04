defmodule SnitchApiWeb.ImageView do
  use SnitchApiWeb, :view
  use JaSerializer.PhoenixView

  location("/products/:id")

  attributes([
    :image_url
  ])

  has_one(
    :variant,
    include: true,
    serializer: SnitchApiWeb.VariantView,
    field: :variant_id,
    type: :variant
  )

  def image_url(images, _conn) do
    images.url
  end
end
