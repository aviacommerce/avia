defmodule AdminAppWeb.TaxonomyController do
  use AdminAppWeb, :controller

  alias Snitch.Domain.Taxonomy
  alias Snitch.Data.Schema.Taxon
  alias Snitch.Data.Schema.Taxonomy, as: TaxonomySchema
  alias AdminAppWeb.TaxonomyView
  alias Snitch.Data.Model.Image
  alias Snitch.Core.Tools.MultiTenancy.Repo
  import Ecto.Query
  import Phoenix.View, only: [render_to_string: 3]

  def show_default_taxonomy(conn, _params) do
    case dump_default_taxonomy() do
      {:ok, taxonomy} ->
        token = get_csrf_token()
        render(conn, "taxonomy.html", taxonomy: taxonomy, token: token)

      {:error, :not_found} ->
        conn
        |> put_flash(:error, "Taxonomy not found")
        |> redirect(to: "/")
    end
  end

  defp dump_default_taxonomy do
    with %TaxonomySchema{} = taxonomy <- Taxonomy.all_taxonomy() |> List.first(),
         taxonomy_dump <- Taxonomy.dump_taxonomy(taxonomy.id) do
      {:ok, taxonomy_dump}
    else
      nil -> {:error, :not_found}
    end
  end

  def create(conn, %{"id" => id, "image" => image, "name" => name, "themes" => themes}) do
    taxon_params = %{name: name, themes: themes, image: Image.handle_image_value(image)}
    parent_taxon = Taxonomy.get_taxon(id)

    with %Taxon{} = parent_taxon <- Taxonomy.get_taxon(id),
         {:ok, taxon} <- Taxonomy.create_taxon(parent_taxon, taxon_params) do
      html =
        render_to_string(
          TaxonomyView,
          "taxon.html",
          taxon: taxon
        )

      conn
      |> put_status(200)
      |> json(%{html: html})
    else
      nil ->
        conn
        |> put_status(:bad_request)
        |> json(%{"error" => "parent taxon does not exist"})

      {:error, _changeset} ->
        conn
        |> put_status(:bad_request)
        |> json(%{"error" => "Failed to create category"})
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
