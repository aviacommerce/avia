defmodule SnitchApiWeb.RatingView do
  use SnitchApiWeb, :view
  use JaSerializer.PhoenixView

  attributes([
    :code,
    :position
  ])

  has_many(
    :rating_options,
    links: [
      related: "/ratings/:id/rating_options",
      self: "/rating_options/:id/relationships/rating_options"
    ],
    serializer: SnitchApiWeb.RatingOptionsView,
    include: false
  )
end

defmodule SnitchApiWeb.RatingOptionsView do
  use SnitchApiWeb, :view
  use JaSerializer.PhoenixView

  attributes([
    :code,
    :position,
    :value
  ])
end
