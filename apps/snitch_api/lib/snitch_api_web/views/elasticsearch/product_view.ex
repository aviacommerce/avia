defmodule SnitchApiWeb.Elasticsearch.ProductView do
  use SnitchApiWeb, :view
  use JaSerializer.PhoenixView

  attributes([
    :id,
    # :parent_id,
    # :has_parent,
    :slug,
    :name,
    :updated_at,
    :images,
    :rating_summary,
    :selling_price,
    :max_retail_price,
    :brand,
    :discount
  ])

  defp source(product), do: product["_source"]

  defp id(product) do
    [_, id] = String.split(product["_id"], "_")
    String.to_integer(id)
  end

  # defp parent_id(product), do: source(product)["parent_id"]

  # defp has_parent(product), do: parent_id(product) == id(product)

  defp slug(product), do: source(product)["slug"]

  defp name(product), do: source(product)["name"]

  defp updated_at(product), do: source(product)["updated_at"]

  defp images(product), do: source(product)["images"]

  defp rating_summary(product), do: source(product)["rating_summary"]

  defp selling_price(product), do: source(product)["selling_price"]

  defp max_retail_price(product), do: source(product)["max_retail_price"]

  defp brand(product), do: source(product)["brand"]

  defp discount(product), do: source(product)["discount"]
end
