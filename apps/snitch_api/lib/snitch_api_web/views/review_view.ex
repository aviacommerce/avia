defmodule SnitchApiWeb.ReviewView do
  use SnitchApiWeb, :view
  use JaSerializer.PhoenixView

  location("/reviews/:id")

  attributes([
    :text,
    :description,
    :locale,
    :name
  ])

  has_one(
    :rating_option_vote,
    serializer: SnitchApiWeb.RatingOptionVote,
    include: true
  )
end

defmodule SnitchApiWeb.RatingOptionVote do
  use SnitchApiWeb, :view
  use JaSerializer.PhoenixView

  has_one(
    :rating_option,
    serializer: SnitchApiWeb.RatingOptionsView,
    include: true
  )
end
