defmodule SnitchApiWeb.LineItemView do
  use SnitchApiWeb, :view
  use JaSerializer.PhoenixView

  location("/line_items/:id")

  attributes([:id, :quantity, :unit_price, :total])
end
