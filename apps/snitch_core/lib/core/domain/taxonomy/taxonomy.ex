defmodule Snitch.Domain.Taxonomy do
  @moduledoc """
  Interface for handling Taxonomy. It provides functions to modify Taxonomy.
  """

  use Snitch.Domain

  import AsNestedSet.Modifiable
  import AsNestedSet.Queriable, only: [dump_one: 2]
  import Ecto.Query

  alias Snitch.Data.Schema.{Taxon, Taxonomy}
  alias Snitch.Tools.Helper.Taxonomy, as: Helper

  @doc """
  Adds child taxon to left, right or child of parent taxon.

  Positon can take follwoing values.
  Position - :left | :right | :child
  """
  @spec add_taxon(Taxon.t(), Taxon.t(), atom) :: Taxon.t()
  def add_taxon(%Taxon{} = parent, %Taxon{} = child, position) do
    %Taxon{child | taxonomy_id: parent.taxonomy.id}
    |> Repo.preload(:taxonomy)
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
    Taxon
    |> AsNestedSet.root(%{taxonomy_id: taxon.taxonomy_id})
    |> AsNestedSet.execute(Repo)
  end

  @doc """
  Traverse in-order the taxonomy tree and return the tuple of root and list of
  traversed taxons
  """
  @spec inorder_list(Taxon.t()) :: {Taxon.t(), [Taxon.t()]}
  def inorder_list(%Taxon{} = root) do
    Taxon
    |> AsNestedSet.traverse(
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
    Taxon
    |> dump_one(%{taxonomy_id: id})
    |> AsNestedSet.execute(Repo)
  end

  @doc """
  Get all leaf Taxons for a Taxonomy
  """
  def get_leaves(%Taxonomy{} = taxonomy) do
    Taxon
    |> AsNestedSet.leaves(%{taxonomy_id: taxonomy.id})
    |> AsNestedSet.execute(Repo)
  end

  @doc """
  Get taxonomy by name
  """
  def get_taxonomy(name) do
    Repo.get_by(Taxonomy, name: name)
  end

  @spec get_all_taxonomy :: [map()]
  def get_all_taxonomy do
    Taxonomy
    |> Repo.all()
    |> Repo.preload(:root)
    |> Enum.map(fn taxonomy -> %{taxonomy | taxons: dump_taxonomy(taxonomy.id)} end)
    |> Enum.map(&Helper.convert_to_map/1)
  end

  def get_child_taxons(taxon_id) do
    Repo.all(from(taxon in Taxon, where: taxon.parent_id == ^taxon_id))
  end
end
