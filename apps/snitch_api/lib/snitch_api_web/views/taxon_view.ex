defmodule SnitchApiWeb.TaxonView do
  use SnitchApiWeb, :view
  use JaSerializer.PhoenixView

  location("/taxons/:id")

  attributes([
    :name,
    :lft,
    :rgt,
    :taxon,
    :taxonomy
  ])
end
