defmodule SnitchApiWeb.TaxonController do
  use SnitchApiWeb, :controller

  alias Snitch.Repo
  alias Snitch.Data.Schema.Taxon

  def index(conn, _params) do
    taxons =
      Repo.all(Taxon)
      |> Repo.preload([:parent, :taxonomy])

    render(
      conn,
      "index.json-api",
      data: taxons,
      opts: [include: "parent"]
    )
  end

  def show(conn, %{"id" => id}) do
    taxon =
      Repo.get!(Taxon, id)
      |> Repo.preload([:parent, :taxonomy])

    render(
      conn,
      "index.json-api",
      data: taxon,
      opts: [include: "parent,taxonomy"]
    )
  end
end
