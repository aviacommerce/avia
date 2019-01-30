defmodule AdminApp.Product.SearchContext do
  import Ecto.Query
  alias Snitch.Data.Schema.Product
  alias Snitch.Core.Tools.MultiTenancy.Repo

  def search_products_by_name(term) do
    query = from(p in Product, where: ilike(p.name, ^"%#{term}%"))
    products = query |> Repo.all() |> Repo.preload(:variants)
  end
end
