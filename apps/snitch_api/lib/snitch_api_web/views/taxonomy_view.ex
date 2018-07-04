defmodule SnitchApiWeb.TaxonomyView do
  use SnitchApiWeb, :view
  use JaSerializer.PhoenixView

  alias Snitch.Data.Schema.User

  location("/taxonomies/:id")

  attributes([
    :name
  ])

  has_one(
    :taxon,
    serializer: SnitchApiWeb.TaxonView,
    include: true,
    field: :root_id,
    type: :taxon
  )
end
