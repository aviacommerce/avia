defmodule SnitchApiWeb.TaxonView do
  use SnitchApiWeb, :view
  use JaSerializer.PhoenixView

  location("/taxons/:id")

  attributes([
    :name,
    :lft,
    :rgt
  ])

  has_one(
    :taxonomy,
    serializer: SnitchApiWeb.TaxonomyView,
    include: true
  )

  has_one(
    :taxon,
    serializer: SnitchApiWeb.TaxonView,
    include: true,
    field: :parent_id,
    type: :taxon
  )
end
