defmodule SnitchApiWeb.TaxonomyController do
  use SnitchApiWeb, :controller

  alias Snitch.Data.Schema.Taxonomy
  alias Snitch.Core.Tools.MultiTenancy.Repo

  alias Snitch.Domain.Taxonomy, as: TaxonomyDomain
  alias Cachex

  @cache_name :avia_cache

  action_fallback(SnitchApiWeb.FallbackController)
  plug(SnitchApiWeb.Plug.DataToAttributes)
  plug(SnitchApiWeb.Plug.LoadUser)

  def index(conn, _params) do
    cache_key = Repo.get_prefix() <> "_taxonomy_list_for_api"

    taxonomy =
      with {:ok, value} <- Cachex.get(@cache_name, cache_key),
           false <- is_nil(value) do
        value
      else
        _ ->
          taxonomy = TaxonomyDomain.get_all_taxonomy()
          Cachex.put(@cache_name, cache_key, taxonomy, ttl: :timer.hours(2))
          taxonomy
      end

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
