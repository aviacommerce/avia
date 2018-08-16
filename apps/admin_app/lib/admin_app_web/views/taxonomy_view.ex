defmodule AdminAppWeb.TaxonomyView do
  use AdminAppWeb, :view

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
end
