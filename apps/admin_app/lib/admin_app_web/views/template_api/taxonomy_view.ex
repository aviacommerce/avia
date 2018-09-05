defmodule AdminAppWeb.TemplateApi.TaxonomyView do
  use AdminAppWeb, :view

  alias Snitch.Data.Schema.VariationTheme

  def get_themes() do
    Snitch.Repo.all(VariationTheme)
    |> Enum.map(fn theme -> {theme.name, theme.id} end)
  end

  def get_selected_values(taxon) do
    taxon.variation_themes
    |> Enum.map(fn x -> x.id end)
  end
end
