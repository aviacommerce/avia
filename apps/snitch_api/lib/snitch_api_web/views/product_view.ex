defmodule SnitchApiWeb.ProductView do
  use SnitchApiWeb, :view
  use JaSerializer.PhoenixView

  location("/products/:slug")

  attributes([
    :name,
    :description,
    :available_on,
    :deleted_at,
    :discontinue_on,
    :slug,
    :meta_description,
    :meta_keywords,
    :meta_title,
    :promotionable
  ])

  has_many(
    :variants,
    serializer: SnitchApiWeb.VariantView,
    include: true
  )

  def variants(product, _conn) do
    Map.get(product, :variants)
  end

  def images(product, _conn) do
    get_in(product, [:variants, :images])
  end
end
