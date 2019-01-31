defmodule AdminApp.Product.SearchContext do
  import Ecto.Query
  alias Snitch.Data.Schema.Product
  alias Snitch.Core.Tools.MultiTenancy.Repo

  def search_products_by_name(term) do
    Product
    |> where([p], ilike(p.name, ^"%#{term}%"))
    |> preload(:variants)
    |> Repo.all()
  end
end
