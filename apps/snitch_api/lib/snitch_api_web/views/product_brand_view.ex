defmodule SnitchApiWeb.ProductBrandView do
  use SnitchApiWeb, :view
  use JaSerializer.PhoenixView
  alias Snitch.Data.Model.ProductBrand

  attributes([
    :name,
    :image_url
  ])

  def image_url(brand, conn) do
    case brand.image do
      nil ->
        nil

      _ ->
        ProductBrand.image_url(brand.image.name, brand)
    end
  end
end
