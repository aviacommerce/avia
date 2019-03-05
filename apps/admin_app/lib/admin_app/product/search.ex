defmodule AdminApp.Product.SearchContext do
  import Ecto.Query
  alias Snitch.Data.Schema.Product
  alias Snitch.Core.Tools.MultiTenancy.Repo

  def search_products_by_name(term) do
    Product
    |> where(
      [p],
      (ilike(p.name, ^"%#{term}%") or ilike(p.sku, ^"%#{term}%")) and p.deleted_at == ^0
    )
    |> preload([:images, :variants])
    |> Repo.all()
  end
end
