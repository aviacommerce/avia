defmodule Snitch.Data.Schema.CountryZoneMember do
  @moduledoc """
  Models a CountryZone member.
  """
  use Snitch.Data.Schema
  alias Snitch.Data.Schema.{Zone, Country}

  @typedoc """
  CountryZoneMember struct.

  ## Fields

  * `zone_id` uniquely determines both `Zone` and `CountryZone`
  """
  @type t :: %__MODULE__{}

  schema "snitch_country_zone_members" do
    belongs_to(:zone, Zone)
    belongs_to(:country, Country)
    timestamps()
  end

  @update_fields ~w(country_id)a
  @create_fields [:zone_id | @update_fields]

  @doc """
  Returns a `Zone` changeset.
  """
  @spec changeset(t, map, :create | :update) :: Ecto.Changeset.t()
  def changeset(country_zone, params, :create) do
    country_zone
    |> cast(params, @create_fields)
    |> validate_required(@create_fields)
    |> foreign_key_constraint(:zone_id)
    |> unique_constraint(:country_id, name: :snitch_country_zone_members_zone_id_country_id_index)
    |> foreign_key_constraint(:country_id)
    |> check_constraint(
      :zone_id,
      name: :country_zone_exclusivity,
      message: "does not refer a country zone"
    )
  end

  def changeset(country_zone, params, :update) do
    country_zone
    |> cast(params, @update_fields)
    |> foreign_key_constraint(:country_id)
    |> unique_constraint(:country_id, name: :snitch_country_zone_members_zone_id_country_id_index)
  end
end
