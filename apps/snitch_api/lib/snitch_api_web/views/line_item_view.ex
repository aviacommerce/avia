defmodule SnitchApiWeb.LineItemView do
  use SnitchApiWeb, :view
  use JaSerializer.PhoenixView

  location("/line_items/:id")

  attributes([:id, :product_id, :quantity, :unit_price, :total_price])

  has_one(
    :product,
    serializer: SnitchApiWeb.ProductView,
    include: false
  )

  def total_price(line_item, _conn) do
    Decimal.mult(Money.to_decimal(line_item.unit_price), line_item.quantity)
    |> Decimal.round(2)
  end

  def unit_price(line_item) do
    Money.round(line_item.unit_price, currency_digits: :cash)
  end
end
