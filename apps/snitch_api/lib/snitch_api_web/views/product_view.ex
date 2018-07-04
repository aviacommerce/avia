defmodule SnitchApiWeb.ProductView do
  use SnitchApiWeb, :view
  use JaSerializer.PhoenixView

  location("/products/:id")

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

  def relationships(product, _conn) do
    %{
      variants: %HasMany{
        serializer: SnitchApiWeb.VariantView,
        include: true,
        links: [
          related: "/products/#{product.id}/variants"
        ],
        data: product.variants
      }
    }
  end
end
