defmodule AdminAppWeb.TaxonomyView do
  use AdminAppWeb, :view

  alias Snitch.Data.Schema.{VariationTheme, Taxonomy}
  import Ecto.Query

  def get_taxon_name({taxon, list}) do
    taxon.name
  end

  def get_taxon_id({taxon, list}) do
    taxon.id
  end

  def check_root({taxon, list}) do
    query = from(t in Taxonomy, select: t.root_id)
    root_ids = Snitch.Repo.all(query)
    Enum.member?(root_ids, taxon.id)
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
