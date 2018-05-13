defmodule Snitch.Domain.Taxonomy do
  @moduledoc """
  Interface for handling Taxonomy. It provides functions to modify Taxonomy.
  """

  use Snitch.Domain

  import AsNestedSet.Modifiable
  import AsNestedSet.Queriable, only: [dump_one: 2]

  alias Snitch.Data.Schema.Taxon

  @doc """
    Adds child taxon to left, right or child of parent taxon.

    Positon can take follwoing values.
    Position - :left | :right | :child
  """
  @spec add_taxon(Taxon.t(), Taxon.t(), atom) :: Taxon.t()
  def add_taxon(%Taxon{} = parent, %Taxon{} = child, position) do
    child =
      %Taxon{child | taxonomy_id: parent.taxonomy.id}
      |> Repo.preload(:taxonomy)

    child
    |> create(parent, position)
    |> AsNestedSet.execute(Repo)
  end

  @doc """
  Adds taxon as root to the taxonomy
  """
  @spec add_root(Taxon.t()) :: Taxon.t()
  def add_root(%Taxon{} = root) do
    root
    |> create(:root)
    |> AsNestedSet.execute(Repo)
  end

  @doc """
  Get the root for the taxonomy of passed the taxon
  """
  @spec get_root(Taxon.t()) :: Taxon.t()
  def get_root(%Taxon{} = taxon) do
    AsNestedSet.root(Taxon, %{taxonomy_id: taxon.taxonomy_id})
    |> AsNestedSet.execute(Repo)
  end

  @doc """
  Traverse in-order the taxonomy tree and return the tuple of root and list of
  traversed taxons
  """
  @spec inorder_list(Taxon.t()) :: {Taxon.t(), [Taxon.t()]}
  def inorder_list(%Taxon{} = root) do
    AsNestedSet.traverse(
      Taxon,
      %{taxonomy_id: root.taxonomy_id},
      [],
      fn node, acc -> {node, [node | acc]} end,
      fn node, acc -> {node, acc} end
    )
    |> AsNestedSet.execute(Repo)
  end

  @doc """
  Dumps the taxonomy in tuple form as follows :

      { %Taxon{name: "root", [
        { %Taxon{name: "child1", [] }},
        { %Taxon{name: "child2", [] }}
      ] }}
  """
  @spec dump_taxonomy(Taxon.t() | integer) :: {Taxon.t(), []}
  def dump_taxonomy(%Taxon{} = taxon) do
    dump_taxonomy(taxon.taxonomy_id)
  end

  def dump_taxonomy(id) do
    dump_one(Taxon, %{taxonomy_id: id})
    |> AsNestedSet.execute(Repo)
  end
end
