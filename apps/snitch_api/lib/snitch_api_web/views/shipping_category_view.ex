defmodule SnitchApiWeb.ShippingCategoryView do
  use SnitchApiWeb, :view
  use JaSerializer.PhoenixView

  attributes([
    :name
  ])

  has_many(
    :variants,
    include: true,
    serializer: SnitchApiWeb.VariantView
  )
end
