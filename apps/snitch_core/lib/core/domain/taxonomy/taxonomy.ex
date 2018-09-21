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
  alias Snitch.Data.Schema.{Taxon, Taxonomy, Image}
  alias Snitch.Tools.Helper.Taxonomy, as: Helper
  alias Snitch.Tools.Helper.ImageUploader

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

  @doc """
  Get taxonomy by id
  """
  def get_taxonomy_by_id(id) do
    Repo.get_by(Taxonomy, id: id)
  end

  def delete_taxonomy(id) do
    id
    |> get_taxonomy_by_id
    |> Repo.delete()
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

  @doc """
  Get taxon by id
  """
  def get_taxon(id) do
    Repo.get_by(Taxon, id: id)
    |> Repo.preload([:image, :taxonomy, :variation_themes])
  end

  def create_taxon(parent_taxon, %{image: "undefined"} = taxon_params) do
    taxon_struct = %Taxon{name: taxon_params.name}
    taxon = add_taxon(parent_taxon, taxon_struct, :child)

    Taxon.update_changeset(
      taxon,
      Map.put(taxon_params, :variation_theme_ids, taxon_params.themes)
    )
    |> Repo.update()
  end

  def create_taxon(parent_taxon, taxon_params) do
    multi =
      Multi.new()
      |> Multi.run(:image, fn _ ->
        QH.create(Image, taxon_params, Repo)
      end)
      |> Multi.run(:taxon, fn _ ->
        taxon_struct = %Taxon{name: taxon_params.name}
        taxon = add_taxon(parent_taxon, taxon_struct, :child)
        {:ok, taxon}
      end)
      |> Multi.run(:image_taxon, fn %{image: image, taxon: taxon} ->
        params = Map.put(%{}, :taxon_image, %{image_id: image.id})

        Taxon.update_changeset(
          taxon,
          Map.put(params, :variation_theme_ids, taxon_params.themes)
        )
        |> Repo.update()
      end)
      |> upload_image_multi(taxon_params.image)
      |> persist()
  end

  @doc """
  Update the given taxon.
  """
  def update_taxon(taxon, %{image: nil} = params) do
    taxon |> Taxon.update_changeset(params) |> Repo.update()
  end

  def update_taxon(taxon, %{image: image} = params) do
    old_image = taxon.image

    Multi.new()
    |> Multi.run(:image, fn _ ->
      QH.create(Image, params, Repo)
    end)
    |> Multi.run(:taxon, fn %{image: image} ->
      params = Map.put(params, :taxon_image, %{image_id: image.id})
      taxon |> Taxon.update_changeset(params) |> Repo.update()
    end)
    |> delete_image_multi(old_image, taxon)
    |> upload_image_multi(params.image)
    |> persist()
  end

  @doc """
  Create a taxonomy with given name.
  """
  def create_taxonomy(name) do
    multi =
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
  Delete a taxon
  """
  def delete_taxon(taxon) do
    taxon |> AsNestedSet.delete() |> AsNestedSet.execute(Repo)
  end

  defp persist(multi) do
    case Repo.transaction(multi) do
      {:ok, _} ->
        {:ok, "success"}

      {:error, _, failed_value, _} ->
        {:error, failed_value}
    end
  end

  def image_url(name, taxon) do
    ImageUploader.url({name, taxon})
  end

  defp upload_image_multi(multi, %Plug.Upload{} = image) do
    Multi.run(multi, :image_upload, fn %{taxon: taxon} ->
      case ImageUploader.store({image, taxon}) do
        {:ok, _} ->
          {:ok, "upload success"}

        _ ->
          {:error, "upload error"}
      end
    end)
  end

  defp delete_image_multi(multi, nil, taxon) do
    multi
  end

  defp delete_image_multi(multi, image, taxon) do
    multi
    |> Multi.run(:remove_from_upload, fn _ ->
      case ImageUploader.delete({image.name, taxon}) do
        :ok ->
          {:ok, "success"}

        _ ->
          {:error, "not_found"}
      end
    end)
    |> Multi.run(:delete_image, fn _ ->
      QH.delete(Image, image.id, Repo)
    end)
  end
end
