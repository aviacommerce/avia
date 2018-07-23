defmodule SnitchApiWeb.VariantImageView do
  use SnitchApiWeb, :view
  use JaSerializer.PhoenixView

  attributes([])

  has_one(
    :variant,
    serializer: SnitchApiWeb.VariantView,
    include: true
  )
end
