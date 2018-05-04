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
    timestamps()
  end

  @update_fields ~w(name description)a
  @create_fields [:zone_type | @update_fields]

  @doc """
  Returns a `Zone` changeset.
  """
  @spec changeset(t, map, :create | :update) :: Ecto.Changeset.t()
  def changeset(zone, params, :create) do
    zone
    |> cast(params, @create_fields)
    |> validate_required(@create_fields)
    |> validate_inclusion(:zone_type, @valid_zone_types)
  end

  def changeset(zone, params, :update) do
    cast(zone, params, @update_fields)
  end
end
