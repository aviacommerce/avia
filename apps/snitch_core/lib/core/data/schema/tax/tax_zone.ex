defmodule Snitch.Data.Schema.TaxZone do
  @moduledoc """
  Models a Tax Zone.

  Tax tax_zone plays an important role in tax calculation.
  The `address` for which tax needs to be calculated is evaluated against the
  tax zone which best encompasses the address.
  A tax zone can be of the type country or state depending on the zone it is
  associated with.
  ### See
    `Snitch.Data.Schema.Zone`

  > The address depends on the type of address set under `calculation_address_type`
  in tax_configuration table. See `Snitch.Data.Schema.TaxConfig`

  A tax zone has multiple tax rates which are then used to calculate the tax for the
  order.
  """

  use Snitch.Data.Schema
  import Ecto.Query
  alias Snitch.Data.Schema.{Zone, CountryZoneMember, StateZoneMember, TaxZone, TaxRate}
  alias Snitch.Data.Model.Zone, as: ZoneModel

  @typedoc """
  - `name`: tax zone name.
  - `is_active?`: checks if the tax zone is active.
  - `zone`: zone with which the tax is associated.

  > `Zones` as such have no restrictions on their members while they are created.
  > However, tax zones which can also be of type of state or country depending on the zone
  > they are associated with needs to have members mutually exclusive of each other.
  > Also, two tax zones can be associate with the same zone.
  """

  @type t :: %__MODULE__{}

  @exculsivity %{
    success: "Tax Zone mutually exclusive of others",
    failure_state: "Tax Zone with one or more states in zone already present",
    failure_country: "Tax Zone with one or more countries in zone already present"
  }

  schema "snitch_tax_zones" do
    field(:name, :string)
    field(:is_active?, :boolean, default: true)
    field(:is_default, :boolean, default: false)

    belongs_to(:zone, Zone, on_replace: :raise)
    has_many(:tax_rates, TaxRate)

    timestamps()
  end

  @required ~w(name zone_id)a
  @optional ~w(is_active? is_default)a
  @permitted @required ++ @optional

  def create_changeset(%__MODULE__{} = tax_zone, params) do
    tax_zone
    |> cast(params, @permitted)
    |> common_changeset()
  end

  def update_changeset(%__MODULE__{} = tax_zone, params) do
    tax_zone
    |> cast(params, @permitted)
    |> common_changeset()
  end

  defp common_changeset(changeset) do
    changeset
    |> validate_required(@required)
    |> unique_constraint(:name)
    |> foreign_key_constraint(:zone_id)
    |> unique_constraint(:zone_id,
      name: :unique_zone_for_tax,
      message: "tax zone exists with supplied zone"
    )
    |> tax_zone_exclusivity()
    |> unique_constraint(:is_default,
      name: :unique_default_tax_zone,
      message: "unique default tax zone"
    )
  end

  # Runs a check for mutual exclusivity with other tax zones so that, no two
  # tax zones can have common members(country, state depending on the zone type).
  defp tax_zone_exclusivity(%Ecto.Changeset{valid?: true} = changeset) do
    with {:ok, zone_id} <- fetch_change(changeset, :zone_id),
         zone when not is_nil(zone) <- ZoneModel.get(zone_id),
         {:ok, _} <- verify_exclusivity(zone, zone.zone_type) do
      changeset
    else
      {:error, message} ->
        add_error(changeset, :zone_id, message)

      :error ->
        changeset

      nil ->
        add_error(changeset, :zone_id, "does not exist")
    end
  end

  defp tax_zone_exclusivity(%Ecto.Changeset{valid?: false} = changeset), do: changeset

  # Runs an exclusivity check for a tax zone of type state identified by "S".
  # A tax zone of type state can only be associated with a zone which does
  # not have states common with another zone which is already associated with
  # a different tax zone.
  # The tax_zone type would be inferred from the type of zone it is being associated
  # with.
  defp verify_exclusivity(zone, "S") do
    zone_members_set = zone_members_set(zone)
    tax_zone_state_set = tax_zone_set(:state)

    case MapSet.disjoint?(zone_members_set, tax_zone_state_set) do
      true ->
        {:ok, @exculsivity.success}

      false ->
        {:error, @exculsivity.failure_state}
    end
  end

  # Runs an exclusivity check for a tax zone of type country identified by "C".
  # A tax zone of type country can only be associated with a zone which does
  # not have countries common with another zone which is already associated with
  # a different tax zone.
  defp verify_exclusivity(zone, "C") do
    zone_members_set = zone_members_set(zone)
    tax_zone_country_set = tax_zone_set(:country)

    case MapSet.disjoint?(zone_members_set, tax_zone_country_set) do
      true ->
        {:ok, @exculsivity.success}

      false ->
        {:error, @exculsivity.failure_country}
    end
  end

  defp zone_members_set(zone) do
    zone
    |> ZoneModel.members()
    |> MapSet.new(fn member -> member.id end)
  end

  defp tax_zone_set(:state) do
    (tz in TaxZone)
    |> from(
      join: s_z_member in StateZoneMember,
      on: tz.zone_id == s_z_member.zone_id,
      select: s_z_member.state_id
    )
    |> Repo.all()
    |> MapSet.new()
  end

  defp tax_zone_set(:country) do
    (tz in TaxZone)
    |> from(
      join: c_z_member in CountryZoneMember,
      on: tz.zone_id == c_z_member.zone_id,
      select: c_z_member.country_id
    )
    |> Repo.all()
    |> MapSet.new()
  end
end
