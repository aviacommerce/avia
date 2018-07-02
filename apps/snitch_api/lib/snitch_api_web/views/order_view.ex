defmodule SnitchApiWeb.OrderView do
  use SnitchApiWeb, :view
  use JaSerializer.PhoenixView

  alias Snitch.Data.Schema.User

  location("/orders/:id")

  attributes([
    :state,
    :user_id,
    :billing_address_id,
    :shipping_address_id,
    :state
  ])

  has_many(
    :line_items,
    serializer: SnitchApiWeb.LineItemView,
    include: true
  )
end
