defmodule Snitch.Domain.Taxonomy do
  @moduledoc """
  Interface for handling Taxonomy. It provides functions to modify Taxonomy.
  """

  use Snitch.Domain
  use Snitch.Data.Model

  import AsNestedSet.Modifiable
  import AsNestedSet.Queriable, only: [dump_one: 2]
  import Ecto.Query

  alias Ecto.Multi
  alias Snitch.Data.Model.Image, as: ImageModel
  alias Snitch.Data.Schema.{Taxon, Taxonomy, Image, Product}
  alias Snitch.Tools.Helper.Taxonomy, as: Helper
  alias Snitch.Tools.Helper.ImageUploader
  alias Snitch.Data.Model.Product, as: ProductModel

  @doc """
  Adds child taxon to left, right or child of parent taxon.

  Positon can take follwoing values.
  Position - :left | :right | :child
  """
  @spec add_taxon(Taxon.t(), Taxon.t(), atom) :: {:ok, Taxon.t()} | {:error, Ecto.Changeset.t()}
  def add_taxon(%Taxon{} = parent, %Taxon{} = child, position) do
    try do
      taxon =
        %Taxon{child | taxonomy_id: parent.taxonomy.id}
        |> Repo.preload(:taxonomy)
        |> create(parent, position)
        |> AsNestedSet.execute(Repo)

      {:ok, taxon}
    rescue
      error in Ecto.InvalidChangesetError ->
        {:error, error.changeset}
    end
  end

  @doc """
  Checks if the taxon is a root taxon.

  Note: If taxon is not asscoaited with taxonomy RuntimeError will be raised.
  """
  @spec is_root?(Taxon.t()) :: boolean()
  def is_root?(%Taxon{} = taxon) do
    taxon = Repo.preload(taxon, :taxonomy)

    case taxon.taxonomy do
      nil ->
        raise "No taxonomy is associated with taxon"

      _ ->
        taxon.id == taxon.taxonomy.root_id
    end
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

  def all_taxonomy, do: Repo.all(Taxonomy)

  def get_default_taxonomy do
    case all_taxonomy() |> List.first() do
      %Taxonomy{} = taxonomy ->
        {:ok, taxonomy}

      nil ->
        {:error, :not_found}
    end
  end

  @doc """
  Get taxonomy by id
  """
  def get_taxonomy_by_id(id) do
    Repo.get_by(Taxonomy, id: id)
  end

  def delete_taxonomy(id) do
    try do
      id
      |> get_taxonomy_by_id
      |> Repo.delete()
    rescue
      e in Ecto.ConstraintError -> {:error, e.message}
    end
  end

  @spec get_all_taxonomy :: [map()]
  def get_all_taxonomy do
    Taxonomy
    |> Repo.all()
    |> Repo.preload(:root)
    |> Enum.map(fn taxonomy -> %{taxonomy | taxons: dump_taxonomy(taxonomy.id)} end)
    |> Enum.map(&Helper.convert_to_map/1)
  end

  @doc """
  Gets all immediate children for a particular category
  """
  @spec get_child_taxons(integer()) :: [Taxon.t()]
  def get_child_taxons(taxon_id) do
    case get_taxon(taxon_id) do
      %Taxon{} = taxon ->
        taxons =
          taxon
          |> AsNestedSet.children()
          |> AsNestedSet.execute(Repo)

        {:ok, taxons}

      _ ->
        {:error, :not_found}
    end
  end

  @doc """
  Gets all the taxons under a taxon tree
  """
  @spec get_all_children_and_self(integer()) :: {:ok, [Taxon.t()]} | {:error, :not_found}
  def get_all_children_and_self(taxon_id) do
    case get_taxon(taxon_id) do
      %Taxon{} = taxon ->
        taxons =
          taxon
          |> AsNestedSet.self_and_descendants()
          |> AsNestedSet.execute(Repo)

        {:ok, taxons}

      _ ->
        {:error, :not_found}
    end
  end

  @doc """
  Gets all the ancestor taxons till the root level
  """
  @spec get_ancestors(integer()) :: {:ok, [Taxon.t()]} | {:error, :not_found}
  def get_ancestors(taxon_id) do
    case Repo.get(Taxon, taxon_id) do
      nil ->
        {:error, :not_found}

      taxon ->
        ancestors =
          taxon
          |> AsNestedSet.ancestors()
          |> AsNestedSet.execute(Repo)

        {:ok, ancestors}
    end
  end

  @doc """
  Get taxon by id
  """
  def get_taxon(id) do
    Repo.get_by(Taxon, id: id)
    |> Repo.preload([:image, :taxonomy, :variation_themes])
  end

  def get_taxon_by_name(name) do
    Repo.get_by(Taxon, name: name)
  end

  def create_taxon(parent_taxon, %{image: nil} = taxon_params) do
    taxon_struct = %Taxon{name: taxon_params.name}

    with {:ok, taxon} <- add_taxon(parent_taxon, taxon_struct, :child) do
      Taxon.update_changeset(
        taxon,
        Map.put(taxon_params, :variation_theme_ids, taxon_params.themes)
      )
      |> Repo.update()
    end
  end

  @doc """
  Updates all category slug based on the name.

  Warning: This methods should be used only when the slug are not present.
  Running this method might change the existing slug if the tree of above a
  category is modified.
  """
  def update_all_categories_slug() do
    Taxon
    |> Repo.all()
    |> Enum.map(&Taxon.changeset(&1, %{}))
    |> Enum.map(&Repo.update(&1))
  end

  def create_taxon(parent_taxon, %{image: image} = taxon_params) do
    multi =
      Multi.new()
      |> Multi.run(:struct, fn _ ->
        taxon_struct = %Taxon{name: taxon_params.name}
        add_taxon(parent_taxon, taxon_struct, :child)
      end)
      |> Multi.run(:image, fn %{struct: struct} ->
        params = %{"image" => Map.put(image, :url, ImageModel.image_url(image.filename, struct))}
        QH.create(Image, params, Repo)
      end)
      |> Multi.run(:association, fn %{image: image, struct: struct} ->
        params = Map.put(%{}, :taxon_image, %{image_id: image.id})

        Taxon.update_changeset(
          struct,
          Map.put(params, :variation_theme_ids, taxon_params.themes)
        )
        |> Repo.update()
      end)
      |> ImageModel.upload_image_multi(taxon_params.image)
      |> ImageModel.persist()
  end

  @doc """
  Update the given taxon.
  """
  def update_taxon(taxon, %{"image" => nil} = params) do
    taxon |> Taxon.update_changeset(params) |> Repo.update()
  end

  def update_taxon(taxon, %{"image" => image} = params) do
    ImageModel.update(Taxon, taxon, params, "taxon_image")
  end

  @doc """
  Create a taxonomy with given name.
  """
  def create_taxonomy(name) do
    Multi.new()
    |> Multi.run(:taxonomy, fn _ ->
      %Taxonomy{name: name} |> Repo.insert()
    end)
    |> Multi.run(:root_taxon, fn %{taxonomy: taxonomy} ->
      taxon = %Taxon{name: name, taxonomy_id: taxonomy.id} |> add_root
      {:ok, taxon}
    end)
    |> Repo.transaction()
  end

  @doc """
  Delete a taxon along with all the products associated with that taxon tree.
  """
  def delete_taxon(taxon_id) do
    case get_taxon(taxon_id) do
      %Taxon{} = taxon ->
        Multi.new()
        |> Multi.run(:delete_products, fn _ -> ProductModel.delete_by_category(taxon) end)
        |> Multi.run(:category, fn _ -> do_delete_taxon(taxon) end)
        |> Repo.transaction()

      nil ->
        {:error, :not_found}
    end
  end

  defp do_delete_taxon(%Taxon{} = taxon) do
    taxon
    |> AsNestedSet.delete()
    |> AsNestedSet.execute(Snitch.Core.Tools.MultiTenancy.Repo)

    {:ok, taxon}
  end
end
