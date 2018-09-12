defmodule SnitchApiWeb.PackageView do
  use SnitchApiWeb, :view
  use JaSerializer.PhoenixView

  attributes([
    :number
  ])

  has_many(
    :shipping_methods,
    serializer: SnitchApiWeb.ShippingMethodView,
    include: true
  )

  has_many(
    :items,
    serializer: SnitchApiWeb.PackageItemView,
    include: true
  )
end

defmodule SnitchApiWeb.PackageItemView do
  use SnitchApiWeb, :view
  use JaSerializer.PhoenixView

  attributes([
    :number,
    :quantity,
    :tax,
    :shipping_tax
  ])

  has_one(
    :product,
    serializer: SnitchApiWeb.ProductView
  )
end
