defmodule SnitchApiWeb.WishListItemView do
  use SnitchApiWeb, :view
  use JaSerializer.PhoenixView

  has_one(
    :variant,
    serializer: SnitchApiWeb.VariantView,
    include: true
  )
end
