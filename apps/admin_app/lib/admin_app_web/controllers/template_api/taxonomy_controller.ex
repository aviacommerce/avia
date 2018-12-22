defmodule AdminAppWeb.TemplateApi.TaxonomyController do
  use AdminAppWeb, :controller

  alias Snitch.Domain.Taxonomy
  alias AdminAppWeb.TemplateApi.TaxonomyView
  alias Snitch.Data.Schema.Taxon
  alias Snitch.Data.Model.{Image, Product}
  alias Snitch.Core.Tools.MultiTenancy.Repo
  import Phoenix.View, only: [render_to_string: 3]

  def index(conn, %{"taxon_id" => taxon_id}) do
    {:ok, categories} = Taxonomy.get_child_taxons(taxon_id)

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
    case Repo.get(Taxon, taxon_id) |> Repo.preload([:variation_themes, :image]) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: %{message: "Taxon not found"}})

      taxon ->
        html = render_to_string(TaxonomyView, "taxon_edit_form.html", %{conn: conn, taxon: taxon})

        conn
        |> put_status(200)
        |> json(%{html: html})
    end
  end

  def update_taxon(conn, %{"taxon" => %{"taxon" => taxon_name, "taxon_id" => taxon_id} = params}) do
    taxon = taxon_id |> Taxonomy.get_taxon()

    params = %{
      "name" => taxon_name,
      "variation_theme_ids" => params["themes"],
      "image" => Image.handle_image_value(params["image"])
    }

    case Taxonomy.update_taxon(taxon, params) do
      {:ok, taxon} ->
        render(conn, "taxon.json", %{taxon: taxon})

      {:error, changeset} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: %{message: "Failed to update category"}})
    end
  end

  def taxon_delete_aggregate(conn, %{"taxon_id" => taxon_id}) do
    with {:ok, categories} <- Taxonomy.get_all_children_and_self(taxon_id) do
      category_count = length(categories)
      product_count = Product.get_products_by_category(taxon_id) |> length

      html =
        render_to_string(TaxonomyView, "category_aggregate.html", %{
          conn: conn,
          category_count: category_count,
          product_count: product_count
        })

      conn
      |> put_status(200)
      |> json(%{html: html})
    else
      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: %{message: "Category not found"}})
    end
  end

  def taxon_delete(conn, params) do
    params = Map.put(params, "tenant", Repo.get_prefix())
    Honeydew.async({:delete_cateory, [params]}, :category_delete_queue)

    conn
    |> put_status(:ok)
    |> json(%{message: "Category delete has started in background"})
  end
end
