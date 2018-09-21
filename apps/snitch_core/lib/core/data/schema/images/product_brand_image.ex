defmodule Snitch.Data.Schema.ProductBrandImage do
  @moduledoc """
  Models a product brand image.
  """

  @type t :: %__MODULE__{}

  use Snitch.Data.Schema
  alias Snitch.Data.Schema.{Image, ProductBrand}

  schema "snitch_product_brand_images" do
    belongs_to(:product_brand, ProductBrand)
    belongs_to(:image, Image)

    timestamps()
  end

  @doc """
  Returns a changeset.
  """
  @spec changeset(t, map) :: Ecto.Changeset.t()
  def changeset(%__MODULE__{} = brand_image, params) do
    brand_image
    |> cast(params, [:product_brand_id, :image_id])
    |> validate_required([:image_id])
  end
end
