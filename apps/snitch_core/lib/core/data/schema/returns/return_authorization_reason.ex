defmodule Snitch.Data.Schema.ReturnAuthorizationReason do
  @moduledoc """
  """

  use Snitch.Data.Schema

  @type t :: %__MODULE__{}

  schema "snitch_return_authorization_reasons" do
    field(:name, :string)
    field(:active, :boolean, default: true)

    timestamps()
  end

  @required_fields [:name]
  @cast_fields [:active | @required_fields]

  @spec create_changeset(t, map) :: Ecto.Changeset.t()
  def create_changeset(%__MODULE__{} = model, params), do: changeset(model, params)

  @spec update_changeset(t, map) :: Ecto.Changeset.t()
  def update_changeset(%__MODULE__{} = model, params), do: changeset(model, params)

  defp changeset(model, params) do
    model
    |> cast(params, @cast_fields)
    |> validate_required(@required_fields)
    |> validate_length(:name, min: 10)
  end
end
