defmodule AdminAppWeb.TemplateApi.TaxonomyController do
  use AdminAppWeb, :controller

  alias Snitch.Domain.Taxonomy
  alias AdminAppWeb.TemplateApi.TaxonomyView
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
end
