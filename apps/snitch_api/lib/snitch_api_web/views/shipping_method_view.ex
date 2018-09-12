defmodule SnitchApiWeb.ShippingMethodView do
  use SnitchApiWeb, :view
  use JaSerializer.PhoenixView

  attributes([
    :cost,
    :name,
    :slug
  ])
end
