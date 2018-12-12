defmodule Snitch.Data.Schema.Image do
  @moduledoc """
  Models an Image.
  """
  use Snitch.Data.Schema
  alias Ecto.Nanoid

  @type t :: %__MODULE__{}

  schema "snitch_images" do
    field(:name, Nanoid)
    field(:image_url, :string)
    field(:image, :any, virtual: true)
    field(:is_default, :boolean, default: false)
    timestamps()
  end

  @doc """
  Returns an `image` changeset.
  """
  @spec changeset(t, map) :: Ecto.Changeset.t()
  def changeset(%__MODULE__{} = image, params) do
    image
    |> cast(params, [:image, :is_default])
    |> put_name_and_url()
  end

  def update_changeset(%__MODULE__{} = image, params) do
    image
    |> cast(params, [:is_default])
    |> put_change(:is_default, params.is_default)
  end

  @doc """
  Returns an `image` changeset.
  """
  @spec changeset(t, map) :: Ecto.Changeset.t()
  def create_changeset(%__MODULE__{} = image, params) do
    image
    |> cast(params, [:image, :is_default])
    |> put_name_and_url()
  end

  def put_name_and_url(changeset) do
    case changeset do
      %Ecto.Changeset{
        valid?: true,
        changes: %{image: %{filename: name, url: url}}
      } ->
        changeset
        |> put_change(:name, name)
        |> put_change(:image_url, url)

      _ ->
        changeset
    end
  end
end
