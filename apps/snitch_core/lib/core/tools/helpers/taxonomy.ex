defmodule Snitch.Tools.Helper.Taxonomy do
  @moduledoc """
  Provides helper funtions to easily create taxonomy.
  """

  alias Snitch.Domain.Taxonomy, as: TaxonomyDomain
  alias Snitch.Data.Schema.{Taxon, Taxonomy}
  alias Snitch.Repo

  @doc """
  Creates taxonomy from the hierarchy passed.

  Structure of hierarchy should be in following format
        {"Brands",
          [
            {"Bags", []},
            {"Mugs", []},
            {"Clothing",
             [
               {"Shirts", []},
               {"T-Shirts", []}
          ]}
        ]}
  """
  @spec create_taxonomy({String.t(), []}) :: Taxonomy.t()
  def create_taxonomy({parent, children}) do
    changeset =
      %Taxonomy{name: parent}
      |> Taxonomy.changeset()

    taxonomy = Repo.insert!(changeset)

    taxon =
      %Taxon{name: parent, taxonomy_id: taxonomy.id}
      |> Repo.preload(:taxonomy)

    root = TaxonomyDomain.add_root(taxon)

    for taxon <- children do
      create_taxon(taxon, root)
    end

    taxonomy
    |> Taxonomy.changeset(%{root_id: root.id})
    |> Repo.update!()
  end

  defp create_taxon({parent, children}, root) do
    child =
      %Taxon{name: parent, taxonomy_id: root.taxonomy_id, parent_id: root.id}
      |> Repo.preload([:taxonomy, :parent])

    root = TaxonomyDomain.add_taxon(root, child, :child)

    for taxon <- children do
      create_taxon(taxon, root)
    end
  end
end
