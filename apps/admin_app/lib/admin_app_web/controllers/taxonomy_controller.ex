defmodule AdminAppWeb.TaxonomyController do
  use AdminAppWeb, :controller

  alias Snitch.Domain.Taxonomy
  alias Snitch.Data.Schema.Taxon
  alias Snitch.Data.Schema.Taxonomy, as: TaxonomySchema
  alias AdminAppWeb.TaxonomyView
  import Ecto.Query
  alias Snitch.Core.Tools.MultiTenancy.Repo
  import Phoenix.View, only: [render_to_string: 3]

  def index(conn, _params) do
    taxonomies = Repo.all(TaxonomySchema)
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

  def create(conn, %{"id" => id, "image" => image, "name" => name, "themes" => themes}) do
    taxon_params = %{name: name, themes: themes, image: image}
    parent_taxon = Taxonomy.get_taxon(id)
    {:ok, taxon} = Taxonomy.create_taxon(parent_taxon, taxon_params)

    html =
      render_to_string(
        TaxonomyView,
        "taxon.html",
        taxon: taxon
      )

    conn
    |> put_status(200)
    |> json(%{html: html})
  end

  def delete_taxonomy(conn, %{"id" => id}) do
    case Taxonomy.delete_taxonomy(id) do
      {:ok, taxonomy} ->
        conn
        |> put_flash(:info, "Taxonomy deleted successfully")
        |> redirect(to: taxonomy_path(conn, :index))

      {:error, changeset} ->
        conn
        |> put_flash(:error, "Taxonomy not deleted. Please try again")
        |> redirect(to: taxonomy_path(conn, :index))
    end
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
        case Taxonomy.delete_taxon(taxon) do
          {_, nil} ->
            taxonomy = Taxonomy.dump_taxonomy(taxon.taxonomy_id)

            conn
            |> put_flash(:info, "Taxon deleted successfully")
            |> render("taxonomy.html", taxonomy: taxonomy, token: token)

          _ ->
            conn
            |> put_flash(:error, "Please try again.")
            |> render("taxonomy.html", taxonomy: taxonomy, token: token)
        end
    end
  end
end
