defmodule SnitchApiWeb.TaxonomyController do
  use SnitchApiWeb, :controller

  alias Snitch.Data.Schema.Taxonomy
  alias Snitch.Core.Tools.MultiTenancy.Repo

  alias Snitch.Domain.Taxonomy, as: TaxonomyDomain
  alias Snitch.Tools.Cache

  action_fallback(SnitchApiWeb.FallbackController)
  plug(SnitchApiWeb.Plug.DataToAttributes)
  plug(SnitchApiWeb.Plug.LoadUser)

  def index(conn, _params) do
    taxonomy =
      Cache.get(
        conn.host <> conn.request_path,
        {
          fn -> TaxonomyDomain.get_all_taxonomy() end,
          []
        }
      )

    json(conn, %{taxonomies: taxonomy})
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
