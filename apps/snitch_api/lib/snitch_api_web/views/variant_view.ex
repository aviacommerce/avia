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
<<<<<<< HEAD
=======
    :cost_price,
>>>>>>> Products API list/search/filter/pagination/sort
    :position,
    :track_inventory,
    :discontinue_on
  ])
<<<<<<< HEAD
=======

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

  def stock_items(variant, _conn) do
    Map.get(variant, :stock_items)
  end

  def images(variant, _conn) do
    Map.get(variant, :images)
  end
>>>>>>> Products API list/search/filter/pagination/sort
end
