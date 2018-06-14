defmodule Snitch.Data.Schema.CountryZoneMember do
  @moduledoc """
  Models a CountryZone member.
  """
  use Snitch.Data.Schema

  alias Snitch.Data.Schema.{Country, Zone}

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
  Returns a `CountryZoneMember` changeset to create a new `country_zone_member`.
  """
  @spec create_changeset(t, map) :: Ecto.Changeset.t()
  def create_changeset(country_zone_member, params) do
    country_zone_member
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

  @doc """
  Returns a `CountryZoneMember` changeset to update the `country_zone_member`.
  """
  @spec update_changeset(t, map) :: Ecto.Changeset.t()
  def update_changeset(country_zone_member, params) do
    country_zone_member
    |> cast(params, @update_fields)
    |> foreign_key_constraint(:country_id)
    |> unique_constraint(:country_id, name: :snitch_country_zone_members_zone_id_country_id_index)
  end
end
