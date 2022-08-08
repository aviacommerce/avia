defmodule Snitch.Data.Schema.Taxon do
  @moduledoc false
  use Snitch.Data.Schema
  use AsNestedSet, scope: [:taxonomy_id]

  import Ecto.Query
  alias Snitch.Data.Schema.{Image, Taxon, Taxonomy, VariationTheme, TaxonImage}
  alias Snitch.Domain.Taxonomy, as: TaxonomyDomain

  @type t :: %__MODULE__{}

  schema "snitch_taxons" do
    field(:name, :string)
    field(:lft, :integer)
    field(:rgt, :integer)
    field(:variation_theme_ids, {:array, :binary}, virtual: true)
    field(:slug, :string)
    field(:tenant, :string, virtual: true)

    has_one(:taxon_image, TaxonImage, on_replace: :delete)
    has_one(:image, through: [:taxon_image, :image])

    many_to_many(
      :variation_themes,
      VariationTheme,
      join_through: "snitch_taxon_themes",
      on_replace: :delete
    )

    belongs_to(:taxonomy, Taxonomy)
    belongs_to(:parent, Taxon)
    timestamps()
  end

  @cast_fields ~w(name parent_id taxonomy_id lft rgt)a
  @update_fields ~w(name)a

  def changeset(taxon, params) do
    taxon
    |> cast(params, @cast_fields)
    |> force_change(:name, taxon.name)
    |> validate_required([:name])
    |> cast_assoc(:taxon_image, with: &TaxonImage.changeset/2)
    |> handle_slug
  end

  defp get_ancestors_slug_text(nil), do: ""

  @doc """
  This method returns the comma separated name of all the taxon above it till
  level 1

  Consider following taxonomy

  Category
  |-- Men
  |   |-- Shirt
  |   |   |-- Full Sleeve
  |   |   |-- Half Sleeve
  |   |-- T-Shirt
  |-- Women
      |-- Shirt
      |-- T-Shirt

  `Full Sleeve` Category under women it would return `Men Shirt`
  """
  defp get_ancestors_slug_text(taxon_id) do
    with %Taxon{} = taxon <- TaxonomyDomain.get_taxon(taxon_id),
         {:ok, ancestors} <- TaxonomyDomain.get_ancestors(taxon_id) do
      {_, ancestors_till_level_1} = List.pop_at(ancestors, 0)

      # Here we exclude the root taxon as we don't include it in slug
      taxons =
        case TaxonomyDomain.is_root?(taxon) do
          true -> ancestors_till_level_1
          false -> ancestors_till_level_1 ++ [taxon]
        end

      Enum.reduce(taxons, "", fn taxon, acc ->
        "#{acc} #{String.trim(taxon.name)}"
      end)
    end
  end

  defp handle_slug(%{changes: %{name: name}} = changeset) do
    parent_id = changeset.data.parent_id || Map.get(changeset.changes, :parent_id, nil)

    ancestors_slug_text = get_ancestors_slug_text(parent_id)

    slug_text = "#{ancestors_slug_text} #{name}"

    changeset
    |> put_change(:slug, generate_slug(slug_text))
    |> unique_constraint(:slug, message: "category with this name alreay exist")
  end

  def generate_slug(text), do: Slugger.slugify_downcase(text, ?_)

  defp handle_slug(changeset), do: changeset

  defp put_assoc_variation_theme(changeset, theme) when theme in [nil, ""] do
    variation_theme_ids = Enum.map(changeset.data.variation_themes, & &1.id)

    changeset
    |> put_change(:variation_theme_ids, variation_theme_ids)
    |> put_assoc(:variation_themes, Enum.map([], &change/1))
  end

  defp put_assoc_variation_theme(changeset, themes) do
    themes = Repo.all(from(vt in VariationTheme, where: vt.id in ^themes))

    put_assoc(changeset, :variation_themes, Enum.map(themes, &change/1))
  end

  def update_changeset(taxon, params) do
    ids = get_variation_theme(params["variation_theme_ids"])

    taxon
    |> Repo.preload([:variation_themes, :taxon_image])
    |> cast(params, @update_fields)
    |> handle_slug
    |> validate_required([:name])
    |> cast_assoc(:taxon_image, with: &TaxonImage.changeset/2)
    |> put_assoc_variation_theme(ids)
  end

  defp get_variation_theme(nil) do
    nil
  end

  defp get_variation_theme("") do
    ""
  end

  defp get_variation_theme(variation_theme_ids) do
    if is_binary(variation_theme_ids),
      do: variation_theme_ids |> String.split(","),
      else: variation_theme_ids
  end
end
