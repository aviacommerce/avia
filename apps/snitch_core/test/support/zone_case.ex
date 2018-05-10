defmodule Snitch.ZoneCase do
  @moduledoc """
  Test helpers to insert zones and zone members.

  ## Sample manifests
  ```
  stock_item_sample_manifest = %{
    "default" => [
      %{count_on_hand: 3, backorderable: true},
      %{count_on_hand: 3, backorderable: true},
      %{count_on_hand: 3, backorderable: true}
    ],
    "backup" => [
      %{count_on_hand: 0},
      %{count_on_hand: 0},
      %{count_on_hand: 6}
    ],
    "origin" => [ # this is the `admin_name` of the `stock_location`
      %{count_on_hand: 3},
      %{count_on_hand: 3},
      %{count_on_hand: 3}
    ]
  }
  """

  alias Snitch.Repo
  alias Snitch.Data.Schema.{Country, State, StateZoneMember, CountryZoneMember}

  @state %{
    name: nil,
    code: nil,
    country_id: nil,
    inserted_at: Ecto.DateTime.utc(),
    updated_at: Ecto.DateTime.utc()
  }

  @country %{
    iso_name: nil,
    iso: nil,
    iso3: nil,
    name: nil,
    numcode: nil,
    inserted_at: Ecto.DateTime.utc(),
    updated_at: Ecto.DateTime.utc()
  }

  @state_zone_member %{
    state_id: nil,
    zone_id: nil,
    inserted_at: Ecto.DateTime.utc(),
    updated_at: Ecto.DateTime.utc()
  }

  @country_zone_member %{
    country_id: nil,
    zone_id: nil,
    inserted_at: Ecto.DateTime.utc(),
    updated_at: Ecto.DateTime.utc()
  }

  def countries_with_manifest(manifest) do
    cs =
      Enum.map(manifest, fn iso ->
        %{@country | iso: iso, iso3: iso <> "_", name: iso, numcode: iso}
      end)

    {_, countries} = Repo.insert_all(Country, cs, returning: true)
    countries
  end

  def states_with_manifest(manifest) do
    ss =
      Enum.map(manifest, fn {name, code, country} ->
        %{@state | country_id: country.id, name: name, code: code}
      end)

    {_, states} = Repo.insert_all(State, ss, returning: true)
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

    {_, state_members} = Repo.insert_all(StateZoneMember, szm, returning: true)
    {_, country_members} = Repo.insert_all(CountryZoneMember, czm, returning: true)

    {state_members, country_members}
  end
end
