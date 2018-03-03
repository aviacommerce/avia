defmodule Core.Snitch.Country do
  use Ecto.Schema
  import Ecto.Changeset
  alias Core.Snitch.State
  alias __MODULE__, as: Country

  schema "snitch_countries" do
    field(:iso_name, :string)
    field(:iso, :string)
    field(:iso3, :string)
    field(:name, :string)
    field(:numcode, :string)
    field(:states_required, :boolean, default: false)
    has_many(:snitch_states, State)

    timestamps()
  end

  def changeset(%Country{} = country, attrs \\ %{}) do
    country
    |> cast(attrs, [:iso, :iso3, :iso_name, :name, :numcode, :states_required])
    |> validate_required([:iso, :iso3, :iso_name, :name, :numcode])
    |> validate_length(:iso, is: 2)
    |> validate_length(:iso3, is: 3)
    |> unique_constraint(:iso)
    |> unique_constraint(:iso3)
    |> unique_constraint(:name)
    |> unique_constraint(:numcode)
    |> build_iso_name
  end

  defp build_iso_name(changeset) do
    name = get_change(changeset, :name)

    if name do
      put_change(changeset, :iso_name, String.upcase(name))
    else
      changeset
    end
  end
end
