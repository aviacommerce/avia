defmodule Snitch.Data.Schema.Taxon do
  @moduledoc false
  use Snitch.Data.Schema
  use AsNestedSet, scope: [:taxonomy_id]

  import Ecto.Query
  alias Snitch.Data.Schema.{Image, Taxon, Taxonomy, VariationTheme, TaxonImage}

  @type t :: %__MODULE__{}

  schema "snitch_taxons" do
    field(:name, :string)
    field(:lft, :integer)
    field(:rgt, :integer)
    field(:variation_theme_ids, {:array, :binary}, virtual: true)

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

  @cast_fields ~w(name parent_id taxonomy_id lft rgt)
  @update_fields ~w(name)

  def changeset(taxon, params) do
    cast(taxon, params, @cast_fields)
    |> validate_required([:name])
    |> cast_assoc(:taxon_image, with: &TaxonImage.changeset/2)
  end

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
    ids = get_variation_theme(params.variation_theme_ids)

    taxon
    |> Repo.preload([:variation_themes, :taxon_image])
    |> cast(params, @update_fields)
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
