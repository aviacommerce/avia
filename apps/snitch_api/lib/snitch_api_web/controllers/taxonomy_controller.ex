defmodule SnitchApiWeb.TaxonomyController do
  use SnitchApiWeb, :controller

  alias Snitch.Data.Schema.Taxonomy
  alias Snitch.Repo

  def index(conn, _params) do
    taxonomies =
      Taxonomy
      |> Repo.all()
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
      Taxonomy
      |> Repo.get!(id)
      |> Repo.preload([:root])

    render(
      conn,
      "show.json-api",
      data: taxonomy,
      opts: [include: "root"]
    )
  end
end
