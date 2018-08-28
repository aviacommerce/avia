defmodule SnitchApiWeb.LineItemView do
  use SnitchApiWeb, :view
  use JaSerializer.PhoenixView

  location("/line_items/:id")

  attributes([:id, :product_id, :quantity, :unit_price])

  has_one(
    :product,
    serializer: SnitchApiWeb.ProductView,
    include: true
  )
end
