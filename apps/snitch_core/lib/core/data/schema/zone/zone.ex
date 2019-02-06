defmodule Snitch.Data.Schema.Zone do
  @moduledoc """
  Models a Zone.

  `Zone` is a "supertype" ie, it is polymorphic. A zone may comprise of states
  (`Snitch.Data.Schema.StateZone`), or countries
  (`Snitch.Data.Schema.CountryZone`).
  """

  use Snitch.Data.Schema

  @valid_zone_types ["S", "C"]
  @readable_valid_zone_types @valid_zone_types
                             |> Enum.map(fn x -> "`#{x}`" end)
                             |> Enum.intersperse(", ")

  @typedoc """
  Zone struct.

  ## Fields

  * `zone_type` is a discriminator, the only valid values are the
    characters [#{@readable_valid_zone_types}].
  """
  @type t :: %__MODULE__{}

  schema "snitch_zones" do
    field(:name, :string)
    field(:description, :string)
    field(:zone_type, :string)
    field(:members, :any, virtual: true)
    field(:is_default, :boolean, default: false)

    timestamps()
  end

  @required_fields ~w(name zone_type)a
  @optional_fields ~w(description is_default)a
  @create_fields @required_fields ++ @optional_fields
  @doc """
  Returns a `Zone` changeset to create a new `zone`.
  """
  @spec create_changeset(t, map) :: Ecto.Changeset.t()
  def create_changeset(zone, params) do
    zone
    |> cast(params, @create_fields)
    |> validate_required(@required_fields)
    |> validate_inclusion(:zone_type, @valid_zone_types)
  end

  @doc """
  Returns a `Zone` changeset to update the `zone`.
  """
  @spec update_changeset(t, map) :: Ecto.Changeset.t()
  def update_changeset(zone, params) do
    zone
    |> cast(params, @create_fields)
    |> validate_required(@required_fields)
  end
end
