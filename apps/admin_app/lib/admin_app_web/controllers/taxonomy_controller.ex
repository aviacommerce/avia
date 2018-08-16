defmodule AdminAppWeb.TaxonomyController do
  use AdminAppWeb, :controller

  alias Snitch.Domain.Taxonomy
  alias Snitch.Data.Schema.Taxon
  alias Snitch.Data.Schema.Taxonomy, as: TaxonomySchema
  alias AdminAppWeb.TaxonomyView
  import Ecto.Query
  import Phoenix.View, only: [render_to_string: 3]

  def index(conn, _params) do
    taxonomies = Snitch.Repo.all(TaxonomySchema)
    render(conn, "index.html", taxonomies: taxonomies)
  end

  def new(conn, _params) do
    token = get_csrf_token()
    render(conn, "new.html", token: token)
  end

  def create_taxonomy(conn, %{"taxonomy" => taxonomy_params}) do
    case Taxonomy.create_taxonomy(taxonomy_params["name"]) do
      {:ok, taxonomy} ->
        conn
        |> put_flash(:info, "Taxonomy created successfully")
        |> redirect(to: taxonomy_path(conn, :index))

      {:error, changeset} ->
        conn
        |> put_flash(:error, "Please try again")
        |> redirect(to: taxonomy_path(conn, :new))
    end
  end

  def edit(conn, %{"id" => id}) do
    taxonomy = Taxonomy.dump_taxonomy(id)
    token = get_csrf_token()
    render(conn, "taxonomy.html", taxonomy: taxonomy, token: token)
  end

  def update_taxon(conn, %{"taxon" => %{"taxon" => taxon_name, "taxon_id" => taxon_id}}) do
    taxon = taxon_id |> Taxonomy.get_taxon()
    params = %{name: taxon_name}

    case Taxonomy.update_taxon(taxon, params) do
      {:ok, taxon} ->
        conn
        |> put_flash(:info, "Taxon updated successfully")
        |> redirect(to: taxonomy_path(conn, :index))

      {:error, changeset} ->
        conn
        |> put_flash(:error, "Taxon update unsuccessful")
        |> redirect(to: taxonomy_path(conn, :index))
    end
  end

  def create(conn, %{"id" => id, "taxon" => taxon}) do
    parent_taxon = Taxonomy.get_taxon(id)
    taxon_params = %Taxon{name: taxon}
    Taxonomy.add_taxon(parent_taxon, taxon_params, :child)

    html =
      render_to_string(
        TaxonomyView,
        "taxon.html",
        name: taxon
      )

    conn
    |> put_status(200)
    |> json(%{html: html})
  end

  def delete(conn, %{"id" => id}) do
    taxon = id |> Taxonomy.get_taxon()
    taxonomy = Taxonomy.dump_taxonomy(taxon.taxonomy_id)
    token = get_csrf_token()

    case taxon do
      nil ->
        conn
        |> put_flash(:error, "Some error occured")
        |> render("taxonomy.html", taxonomy: taxonomy, token: token)

      taxon ->
        root_taxon =
          taxon
          |> check_if_root(conn)

        case root_taxon do
          true ->
            conn
            |> put_flash(:error, "Root taxon can't be deleted.")
            |> render("taxonomy.html", taxonomy: taxonomy, token: token)

          false ->
            Taxonomy.delete_taxon(taxon)
            taxonomy = Taxonomy.dump_taxonomy(taxon.taxonomy_id)

            conn
            |> put_flash(:info, "Taxon deleted successfully")
            |> render("taxonomy.html", taxonomy: taxonomy, token: token)
        end
    end
  end

  defp check_if_root(taxon, conn) do
    query = from(t in TaxonomySchema, select: t.root_id)
    root_ids = Snitch.Repo.all(query)
    Enum.member?(root_ids, taxon.id)
  end
end
