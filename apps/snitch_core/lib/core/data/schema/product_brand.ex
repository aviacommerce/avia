defmodule Snitch.Data.Schema.ProductBrand do
  @moduledoc """
  Models a Product Brand.
  """
  use Snitch.Data.Schema

  alias Snitch.Data.Schema.{Product, ProductBrandImage}

  @type t :: %__MODULE__{}

  schema "snitch_product_brands" do
    field(:name, :string, null: false)
    field(:tenant, :string, virtual: true)
    timestamps()

    has_many(:products, Product, foreign_key: :brand_id)
    has_one(:brand_image, ProductBrandImage, on_replace: :delete)
    has_one(:image, through: [:brand_image, :image])
  end

  @required_fields ~w(name)a

  def create_changeset(model, params) do
    common_changeset(model, params)
  end

  def update_changeset(model, params) do
    common_changeset(model, params)
  end

  def delete_changeset(model, params) do
    model
    |> cast(params, @required_fields)
    |> no_assoc_constraint(:products, message: "Cannot delete as products are associated")
  end

  defp common_changeset(model, params) do
    model
    |> Repo.preload([:brand_image])
    |> cast(params, @required_fields)
    |> validate_required(@required_fields)
    |> cast_assoc(:brand_image, with: &ProductBrandImage.changeset/2)
  end
end
