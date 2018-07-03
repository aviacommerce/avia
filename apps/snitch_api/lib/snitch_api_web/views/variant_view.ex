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
    :position,
    :track_inventory,
    :discontinue_on
  ])
end
