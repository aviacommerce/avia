defmodule SnitchApiWeb.StockLocationView do
  use SnitchApiWeb, :view
  use JaSerializer.PhoenixView

  attributes([
    :name,
    :default,
    :address_line_1,
    :address_line_2,
    :city,
    :zip_code,
    :phone,
    :propagate_all_variants,
    :backorderable_default,
    :active
  ])

  has_many(
    :stock_items,
    serializer: SnitchApiWeb.StockItemView,
    include: true
  )

  has_many(
    :stock_movements,
    serializer: SnitchApiWeb.StockMovementView,
    include: true
  )

  has_one(
    :state,
    serializer: StateView,
    include: true
  )

  has_one(
    :country,
    serializer: CountryView,
    include: true
  )
end
