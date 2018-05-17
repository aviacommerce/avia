defmodule Snitch.Data.Model.ZoneTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase

  import Snitch.Factory
  import Snitch.ZoneCase

  alias Snitch.Domain.Zone
  alias Snitch.Data.Model.{StateZone, CountryZone}

  setup :zones

  setup %{zones: [indian, america, apac]} do
    [us, ind, china, jp] = countries = countries_with_manifest(~w(US IN CH JP))

    [ka, ap, _up, _tokyo, _ny] =
      states =
      states_with_manifest([
        {"KA", "IN-KA", ind},
        {"AP", "IN-AP", ind},
        {"UP", "IN-UP", ind},
        {"13", "JP-13", jp},
        {"NY", "US-NY", us}
      ])

    zone_members([
      {indian, [ka, ap]},
      {america, [us]},
      {apac, [ind, china, jp]}
    ])

    [
      countries: countries,
      states: states,
      indian: StateZone.fetch_members(indian),
      america: CountryZone.fetch_members(america),
      apac: CountryZone.fetch_members(apac)
    ]
  end

  @tag country_zone_count: 2, state_zone_count: 1
  test "KA and AP get apac and south-india zone", context do
    %{indian: _indian, apac: _apac, countries: [_, ind, _, _], states: [ka, ap, _, _, _]} =
      context

    ka_address = insert(:address, state: ka, country: ind)
    ap_address = insert(:address, state: ap, country: ind)

    {state, country} = Zone.common(ka_address, ap_address)
    assert [_indian] = state
    assert [_apac] = country
  end

  @tag country_zone_count: 2, state_zone_count: 1
  test "KA and UP get apac zone only", context do
    %{apac: _apac, countries: [_, ind, _, _], states: [ka, _, up, _, _]} = context
    ka_address = insert(:address, state: ka, country: ind)
    up_address = insert(:address, state: up, country: ind)

    {state, country} = Zone.common(ka_address, up_address)
    assert [] = state
    assert [_apac] = country
  end

  @tag country_zone_count: 2, state_zone_count: 1
  test "KA and Tokyo get apac zone", context do
    %{apac: _apac, countries: [_, ind, _, jp], states: [ka, _, _, tokyo, _]} = context
    ka_address = insert(:address, state: ka, country: ind)
    tokyo_address = insert(:address, state: tokyo, country: jp)

    {state, country} = Zone.common(ka_address, tokyo_address)
    assert [] = state
    assert [_apac] = country
  end

  @tag country_zone_count: 2, state_zone_count: 1
  test "KA and NY get no zone", context do
    %{countries: [us, ind, _, _], states: [ka, _, _, _, ny]} = context
    ka_address = insert(:address, state: ka, country: ind)
    ny_address = insert(:address, state: ny, country: us)

    {state, country} = Zone.common(ka_address, ny_address)
    assert [] = state
    assert [] = country
  end

  @tag country_zone_count: 2, state_zone_count: 1
  test "JP and CH get apac zone (even without state)", context do
    %{apac: _apac, countries: [_, _, ch, jp]} = context
    ch_address = insert(:address, state: nil, country: ch)
    jp_address = insert(:address, state: nil, country: jp)

    {state, country} = Zone.common(ch_address, jp_address)
    assert [] = state
    assert [_apac] = country
  end

  @tag country_zone_count: 2, state_zone_count: 1
  test "JP and UP get apac zone (even without JP state)", context do
    %{apac: _apac, countries: [_, ind, _, jp], states: [_, _, up, _, _]} = context
    up_address = insert(:address, state: up, country: ind)
    jp_address = insert(:address, state: nil, country: jp)

    {state, country} = Zone.common(up_address, jp_address)
    assert [] = state
    assert [_apac] = country
  end
end
