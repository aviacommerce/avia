defmodule Snitch.Data.Schema.Country do
  @moduledoc """
  Models a Country.
  """

  use Snitch.Data.Schema
  alias Snitch.Data.Schema.State

  @type t :: %__MODULE__{}

  schema "snitch_countries" do
    field(:iso_name, :string)
    field(:iso, :string)
    field(:iso3, :string)
    field(:name, :string)
    field(:numcode, :string)
    field(:states_required, :boolean, default: false)
    has_many(:states, State)

    timestamps()
  end

  @spec changeset(t, map) :: Ecto.Changeset.t()
  def changeset(%__MODULE__{} = country, params) do
    country
    |> cast(params, [:iso, :iso3, :iso_name, :name, :numcode, :states_required])
    |> validate_required([:iso, :iso3, :iso_name, :name, :numcode])
    |> validate_length(:iso, is: 2)
    |> validate_length(:iso3, is: 3)
    |> unique_constraint(:iso)
    |> unique_constraint(:iso3)
    |> unique_constraint(:name)
    |> unique_constraint(:numcode)
    |> build_iso_name
  end

  @spec build_iso_name(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  defp build_iso_name(changeset) do
    name = get_change(changeset, :name)

    if name do
      put_change(changeset, :iso_name, String.upcase(name))
    else
      changeset
    end
  end
end
