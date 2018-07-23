defmodule SnitchApiWeb.VariantView do
  use SnitchApiWeb, :view
  use JaSerializer.PhoenixView

  location("/products/:id/variants/")

  attributes([
    :sku,
    :weight,
    :height,
    :width,
    :depth,
    :selling_price,
    :cost_price,
    :position,
    :track_inventory,
    :discontinue_on
  ])

  has_one(
    :shipping_category,
    serializer: SnitchApiWeb.ShippingCategoryView,
    include: true,
    field: :shipping_category_id,
    type: :shipping_category
  )

  has_one(
    :product,
    serializer: SnitchApiWeb.ProductView,
    include: true,
    field: :product_id,
    type: :product
  )

  has_many(
    :images,
    serializer: SnitchApiWeb.ImageView,
    include: true,
    field: :image_id,
    type: :image
  )
end
