defmodule SnitchApiWeb.ProductBrandController do
  use SnitchApiWeb, :controller

  alias SnitchApiWeb.ProductBrandView
  alias Snitch.Data.Model.ProductBrand
  alias Snitch.Core.Tools.MultiTenancy.Repo

  def index(conn, _params) do
    brands = ProductBrand.get_all() |> Repo.preload(:image)

    render(
      conn,
      ProductBrandView,
      "index.json-api",
      data: brands
    )
  end
end
