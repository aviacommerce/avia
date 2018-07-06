defmodule SnitchApiWeb.LineItemView do
  use SnitchApiWeb, :view
  use JaSerializer.PhoenixView

  location("/line_items/:id")

  attributes([:id, :variant_id, :quantity, :unit_price])
end
