defmodule Snitch.Data.Schema.ProductPrototype do
  @moduledoc """
  Models Prodcut Prototype

  Prototype helps in creating product easily as it has information
  to create product. Following info is stored by protoype:
  - Taxon - Protoype stores Taxon (Category) which tells that product can fall
     under which category
  - Option types - Attributes on which the product variants can be created
  - Properties - Attributes that are common to product.
  """

  use Snitch.Data.Schema
  import Ecto.Query
  alias Snitch.Data.Schema.{Property, Taxon, VariationTheme}

  @type t :: %__MODULE__{}

  schema "snitch_product_prototype" do
    field(:name, :string)
    field(:variation_theme_ids, {:array, :binary}, virtual: true)
    field(:property_ids, {:array, :binary}, virtual: true)

    belongs_to(:taxon, Taxon)

    many_to_many(
      :variation_themes,
      VariationTheme,
      join_through: "snitch_prototype_themes",
      on_replace: :delete
    )

    many_to_many(
      :properties,
      Property,
      join_through: "snitch_prototype_property",
      on_replace: :delete
    )

    timestamps()
  end

  @create_params ~w(name taxon_id)a

  @doc """
  Returns a changeset to create new Product Prototype
  """
  def create_changeset(model, params) do
    common_changeset(model, params)
  end

  @doc """
  Returns a changeset to update a Product Prototype
  """
  def update_changeset(model, params) do
    common_changeset(model, params)
  end

  defp common_changeset(model, params) do
    model
    |> Repo.preload([:variation_themes, :properties])
    |> cast(params, @create_params)
    |> validate_required(@create_params)
    |> unique_constraint(:name)
    |> put_assoc_variation_theme(params["variation_theme_ids"])
    |> put_assoc_property(params["property_ids"])
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

  defp put_assoc_property(changeset, properties) when properties in [nil, ""] do
    properties = Enum.map(changeset.data.properties, & &1.id)

    changeset
    |> put_change(:property_ids, properties)
    |> put_assoc(:properties, Enum.map([], &change/1))
  end

  defp put_assoc_property(changeset, properties) do
    properties = Repo.all(from(p in Property, where: p.id in ^properties))

    put_assoc(changeset, :properties, Enum.map(properties, &change/1))
  end
end
