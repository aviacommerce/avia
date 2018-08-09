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
    :promotionable,
    :selling_price,
    :max_retail_price
  ])

  has_many(
    :variants,
    serializer: SnitchApiWeb.ProductView,
    include: true
  )

  has_many(
    :options,
    serializer: SnitchApiWeb.ProductOptionValueView,
    include: true
  )

  has_many(
    :reviews,
    serializer: SnitchApiWeb.ReviewView,
    include: true
  )

  has_one(
    :theme,
    serializer: SnitchApiWeb.VariationThemeView,
    include: true
  )

  def render("rating_summary.json-api", %{data: data, id: id}) do
    %{
      links: %{
        self: "products/#{id}/rating-summary"
      },
      data: data
    }
  end
end
