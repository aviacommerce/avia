defmodule SnitchApiWeb.Elasticsearch.Product.SuggestView do
  use SnitchApiWeb, :view
  use JaSerializer.PhoenixView

  attributes([
    :id,
    :name,
    :brand,
    :category
  ])

  defp source(product), do: product["_source"]

  defp id(product) do
    [_, id] = String.split(product["_id"], "_")
    String.to_integer(id)
  end

  defp name(product), do: source(product)["name"]

  defp brand(product), do: source(product)["brand"]

  defp category(product), do: source(product)["category"]["direct_parent"]
end
