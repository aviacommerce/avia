defmodule SnitchApiWeb.Elasticsearch.Product.SuggestView do
  use SnitchApiWeb, :view
  use JaSerializer.PhoenixView

  attributes([
    :id,
    :name,
    :brand,
    :category,
    :term
  ])

  defp source(product), do: product["_source"]

  defp id(product) do
    [_, id] = String.split(product["_id"], "_")
    String.to_integer(id)
  end

  defp name(product), do: source(product)["name"]

  defp brand(product), do: source(product)["brand"]

  # A category is stored like this :
  #
  #   "category" : {
  #     "paths" : "Category:Kids:Toys",
  #     "direct_parent" : "Toys",
  #     "all_parents" : [
  #       "Category",
  #       "Kids",
  #       "Toys"
  #     ]
  #   }
  defp category(product), do: List.first(source(product)["category"]["all_parents"] || [])

  defp term(product), do: product["text"] |> String.split(" ") |> List.first()
end
