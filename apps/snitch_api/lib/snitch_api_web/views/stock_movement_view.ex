defmodule SnitchApiWeb.StockMovementView do
  use SnitchApiWeb, :view
  use JaSerializer.PhoenixView

  attributes([
    :quantity,
    :action,
    :orginator_type,
    :orginator_id
  ])

  has_one(
    :stock_item,
    serializer: SnitchApiWeb.StockItemView,
    include: true
  )
end
