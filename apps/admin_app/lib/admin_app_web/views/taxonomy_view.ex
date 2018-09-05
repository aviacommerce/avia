defmodule AdminAppWeb.TaxonomyView do
  use AdminAppWeb, :view

  alias Snitch.Data.Schema.VariationTheme

  def get_taxon_name({taxon, list}) do
    taxon.name
  end

  def get_taxon_id({taxon, list}) do
    taxon.id
  end

  def has_children({taxon, list}) do
    length(list) > 0
  end

  def get_children({taxon, list}) do
    list
  end

  def get_themes() do
    Snitch.Repo.all(VariationTheme)
    |> Enum.map(fn theme -> {theme.name, theme.id} end)
  end
end
