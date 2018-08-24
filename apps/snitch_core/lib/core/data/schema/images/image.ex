defmodule Snitch.Data.Schema.Image do
  @moduledoc """
  Models an Image.
  """
  use Snitch.Data.Schema

  @type t :: %__MODULE__{}

  schema "snitch_images" do
    field(:name, :string)
    field(:image, :any, virtual: true)
    timestamps()
  end

  @doc """
  Returns an `image` changeset.
  """
  @spec changeset(t, map) :: Ecto.Changeset.t()
  def changeset(%__MODULE__{} = image, params) do
    image
    |> cast(params, [:image])
    |> put_name()
  end

  def put_name(changeset) do
    case changeset do
      %Ecto.Changeset{
        valid?: true,
        changes: %{image: %Plug.Upload{content_type: "image/" <> _, filename: name}}
      } ->
        put_change(changeset, :name, name)

      _ ->
        changeset
    end
  end
end
