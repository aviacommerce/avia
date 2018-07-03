defmodule SnitchApiWeb.OrderView do
  use SnitchApiWeb, :view
  use JaSerializer.PhoenixView

  location("/orders/:id")

  attributes([
    :state,
    :user_id,
    :billing_address_id,
    :shipping_address_id
  ])

  has_many(
    :line_items,
    serializer: SnitchApiWeb.LineItemView,
    include: true
  )
end
