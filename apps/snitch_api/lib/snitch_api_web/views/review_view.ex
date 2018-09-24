defmodule SnitchApiWeb.ReviewView do
  use SnitchApiWeb, :view
  use JaSerializer.PhoenixView

  location("/reviews/:id")

  attributes([
    :title,
    :description,
    :locale,
    :name,
    :updated_at
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
