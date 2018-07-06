defmodule SnitchApiWeb.StockItemView do
  use SnitchApiWeb, :view
  use JaSerializer.PhoenixView

  attributes([
    :count_on_hand,
    :backorderable
  ])

  has_one(
    :variant,
    serializer: SnitchApiWeb.VariantView,
    include: true
  )

  has_one(
    :stock_location,
    serializer: SnitchApiWeb.StockLocationView,
    include: true
  )
end
