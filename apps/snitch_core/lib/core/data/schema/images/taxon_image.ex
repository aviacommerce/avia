defmodule Snitch.Data.Schema.TaxonImage do
  @moduledoc """
  Models a taxon image.
  """

  @type t :: %__MODULE__{}

  use Snitch.Data.Schema
  alias Snitch.Data.Schema.{Image, Taxon}

  schema "snitch_taxon_images" do
    belongs_to(:taxon, Taxon)
    belongs_to(:image, Image)

    timestamps()
  end

  @doc """
  Returns a changeset.
  """
  @spec changeset(t, map) :: Ecto.Changeset.t()
  def changeset(%__MODULE__{} = taxon_image, params) do
    taxon_image
    |> cast(params, [:taxon_id, :image_id])
    |> validate_required([:image_id])
  end
end
