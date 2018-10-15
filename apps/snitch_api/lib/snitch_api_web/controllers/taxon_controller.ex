defmodule SnitchApiWeb.TaxonController do
  use SnitchApiWeb, :controller

  alias Snitch.Data.Schema.Taxon
  alias Snitch.Core.Tools.MultiTenancy.Repo

  action_fallback(SnitchApiWeb.FallbackController)

  plug(SnitchApiWeb.Plug.DataToAttributes)
  plug(SnitchApiWeb.Plug.LoadUser)

  def index(conn, _params) do
    taxons =
      Taxon
      |> Repo.all()
      |> Repo.preload([:parent, :taxonomy])

    render(
      conn,
      "index.json-api",
      data: taxons,
      opts: [include: "parent,taxonomy"]
    )
  end

  def show(conn, %{"id" => id}) do
    taxon =
      Taxon
      |> Repo.get!(id)
      |> Repo.preload([:parent, :taxonomy])

    render(
      conn,
      "index.json-api",
      data: taxon,
      opts: [include: "parent,taxonomy"]
    )
  end
end
