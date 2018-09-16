defmodule AdminAppWeb.TemplateApi.TaxonomyView do
  use AdminAppWeb, :view

  alias Snitch.Data.Schema.VariationTheme
  alias Snitch.Domain.Taxonomy

  def get_themes() do
    Snitch.Repo.all(VariationTheme)
    |> Enum.map(fn theme -> {theme.name, theme.id} end)
  end

  def get_selected_values(taxon) do
    taxon.variation_themes
    |> Enum.map(fn x -> x.id end)
  end

  def get_image_url(image, taxon) do
    Taxonomy.image_url(image.name, taxon)
  end

  def render("taxon.json", %{taxon: taxon}) do
    Map.take(taxon, [:id, :name, :parent_id])
  end
end
