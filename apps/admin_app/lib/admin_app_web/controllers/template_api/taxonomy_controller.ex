defmodule AdminAppWeb.TemplateApi.TaxonomyController do
  use AdminAppWeb, :controller

  alias Snitch.Domain.Taxonomy
  alias AdminAppWeb.TemplateApi.TaxonomyView
  alias Snitch.Data.Schema.Taxon
  alias Snitch.Core.Tools.MultiTenancy.Repo
  import Phoenix.View, only: [render_to_string: 3]

  def index(conn, %{"taxon_id" => taxon_id}) do
    categories = Taxonomy.get_child_taxons(taxon_id)

    if(length(categories) > 0) do
      html = render_to_string(TaxonomyView, "taxons.html", taxons: categories)

      conn
      |> put_status(200)
      |> json(%{html: html})
    else
      html = render_to_string(TaxonomyView, "add_product.html", id: taxon_id)

      conn
      |> put_status(200)
      |> json(%{html: html})
    end
  end

  def taxon_edit(conn, %{"taxon_id" => taxon_id}) do
    taxon = Repo.get(Taxon, taxon_id) |> Repo.preload([:variation_themes, :image])
    html = render_to_string(TaxonomyView, "taxon_edit_form.html", %{conn: conn, taxon: taxon})

    conn
    |> put_status(200)
    |> json(%{html: html})
  end

  def update_taxon(conn, %{"taxon" => %{"taxon" => taxon_name, "taxon_id" => taxon_id} = params}) do
    taxon = taxon_id |> Taxonomy.get_taxon()

    params = %{
      name: taxon_name,
      variation_theme_ids: params["themes"],
      image: handle_image_value(params["image"])
    }

    case Taxonomy.update_taxon(taxon, params) do
      {:ok, taxon} ->
        render(conn, "taxon.json", %{taxon: taxon})

      {:error, changeset} ->
        conn
        |> put_status(:bad_request)
        |> json(%{})
    end
  end

  defp handle_image_value(%Plug.Upload{} = file), do: file
  defp handle_image_value(_), do: nil
end
