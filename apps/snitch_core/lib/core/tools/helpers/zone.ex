defmodule Snitch.Tools.Helper.Zone do
  @moduledoc """
  Test helpers to insert zones and zone members.
  """

  alias Snitch.Data.Schema.{Country, CountryZoneMember, State, StateZoneMember, Zone}
  alias Snitch.Core.Tools.MultiTenancy.Repo

  @zone %{
    name: nil,
    description: nil,
    zone_type: nil,
    inserted_at: DateTime.utc_now(),
    updated_at: DateTime.utc_now()
  }

  @state %{
    name: nil,
    code: nil,
    country_id: nil,
    inserted_at: DateTime.utc_now(),
    updated_at: DateTime.utc_now()
  }

  @country %{
    iso_name: nil,
    iso: nil,
    iso3: nil,
    name: nil,
    numcode: nil,
    inserted_at: DateTime.utc_now(),
    updated_at: DateTime.utc_now()
  }

  @state_zone_member %{
    state_id: nil,
    zone_id: nil,
    inserted_at: DateTime.utc_now(),
    updated_at: DateTime.utc_now()
  }

  @country_zone_member %{
    country_id: nil,
    zone_id: nil,
    inserted_at: DateTime.utc_now(),
    updated_at: DateTime.utc_now()
  }

  def countries_with_manifest(manifest) do
    cs =
      Enum.map(manifest, fn iso ->
        %{@country | iso: iso, iso3: iso <> "_", name: iso, numcode: iso}
      end)

    {_, countries} = Repo.insert_all(Country, cs, on_conflict: :nothing, returning: true)
    countries
  end

  def states_with_manifest(manifest) do
    ss =
      Enum.map(manifest, fn {name, code, country} ->
        %{@state | country_id: country.id, name: name, code: code}
      end)

    {_, states} = Repo.insert_all(State, ss, on_conflict: :nothing, returning: true)
    states
  end

  def zone_members(manifest) do
    zm =
      manifest
      |> Enum.map(fn
        {%{zone_type: "S"} = zone, states} ->
          Enum.map(states, fn state ->
            %{@state_zone_member | zone_id: zone.id, state_id: state.id}
          end)

        {%{zone_type: "C"} = zone, countries} ->
          Enum.map(countries, fn country ->
            %{@country_zone_member | zone_id: zone.id, country_id: country.id}
          end)
      end)
      |> List.flatten()

    szm = Enum.filter(zm, fn member -> Map.has_key?(member, :state_id) end)
    czm = Enum.filter(zm, fn member -> Map.has_key?(member, :country_id) end)

    {_, state_members} =
      Repo.insert_all(StateZoneMember, szm, on_conflict: :nothing, returning: true)

    {_, country_members} =
      Repo.insert_all(CountryZoneMember, czm, on_conflict: :nothing, returning: true)

    {state_members, country_members}
  end

  @doc """
  Creates zones according to the manifest.

  ## Sample manifest
  ```
  %{
    "domestic" => %{zone_type: "S", description: "something"}
  }
  ```
  """
  def zones_with_manifest(manifest) do
    zones =
      Enum.map(manifest, fn {name, params} ->
        Map.merge(%{@zone | name: name}, params)
      end)

    {_, zones} = Repo.insert_all(Zone, zones, on_conflict: :nothing, returning: true)
    zones
  end
end
