defmodule Snitch.Data.Schema.StoreLogo do
  @moduledoc """
  Models a logo for the store.
  """

  @type t :: %__MODULE__{}

  use Snitch.Data.Schema
  alias Snitch.Data.Schema.{Image, GeneralConfiguration}

  schema "snitch_store_logos" do
    belongs_to(:general_configuration, GeneralConfiguration)
    belongs_to(:image, Image)

    timestamps()
  end

  @doc """
  Returns a changeset.
  """
  @spec changeset(t, map) :: Ecto.Changeset.t()
  def changeset(%__MODULE__{} = store_image, params) do
    store_image
    |> cast(params, [:general_configuration_id, :image_id])
    |> validate_required([:image_id])
  end
end
