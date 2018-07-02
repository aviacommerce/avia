defmodule SnitchApiWeb.TaxonomyController do
  use SnitchApiWeb, :controller

  alias Snitch.Repo
  alias Snitch.Data.Schema.Taxonomy

  def index(conn, _params) do
    taxonomies =
      Repo.all(Taxonomy)
      |> Repo.preload([:root])

    render(
      conn,
      "index.json-api",
      data: taxonomies,
      opts: [include: "root"]
    )
  end

  def show(conn, %{"id" => id}) do
    taxonomy =
      Repo.get!(Taxonomy, id)
      |> Repo.preload([:root])

    render(
      conn,
      "show.json-api",
      data: taxonomy,
      opts: [include: "root"]
    )
  end
end
