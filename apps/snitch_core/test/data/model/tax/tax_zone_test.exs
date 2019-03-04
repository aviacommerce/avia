defmodule Snitch.Data.Model.TaxZoneTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase
  import Snitch.Factory
  alias Snitch.Data.Model.TaxZone

  setup :states
  setup :countries

  describe "create/1" do
    @tag state_count: 3
    test "fails if selected zone is not mutually exclusive, type state", context do
      zone_1 = insert(:zone, zone_type: "S")
      %{states: states} = context
      setup_state_zone_members(zone_1, states)
      [state_1, _, _] = states
      insert(:tax_zone, zone: zone_1)

      zone_2 = insert(:zone, zone_type: "S")
      [states: new_states] = states(%{state_count: 2})
      setup_state_zone_members(zone_2, [state_1 | new_states])

      params = %{name: "APACzone", zone_id: zone_2.id}
      assert {:error, changeset} = TaxZone.create(params)

      assert %{
               zone_id: ["Tax Zone with one or more states in zone already present"]
             } == errors_on(changeset)
    end

    @tag state_count: 3
    test "success if selected zone is mutually exclusive, type state", context do
      zone_1 = insert(:zone, zone_type: "S")
      %{states: states} = context
      setup_state_zone_members(zone_1, states)
      insert(:tax_zone, zone: zone_1)

      zone_2 = insert(:zone, zone_type: "S")
      [states: new_states] = states(%{state_count: 2})
      setup_state_zone_members(zone_2, new_states)

      params = %{name: "APACzone", zone_id: zone_2.id}
      assert {:ok, _zone} = TaxZone.create(params)
    end

    @tag state_count: 3
    test "fails for missing params" do
      params = %{}
      assert {:error, changeset} = TaxZone.create(params)
      assert %{name: ["can't be blank"], zone_id: ["can't be blank"]} == errors_on(changeset)
    end

    @tag country_count: 3
    test "fails if selected zone is not mutually exclusive, type country", context do
      zone_1 = insert(:zone, zone_type: "C")
      %{countries: countries} = context
      setup_country_zone_members(zone_1, countries)
      [country_1, _, _] = countries
      insert(:tax_zone, zone: zone_1)

      zone_2 = insert(:zone, zone_type: "C")
      [countries: new_countries] = countries(%{country_count: 2})
      setup_country_zone_members(zone_2, [country_1 | new_countries])

      params = %{name: "APACzone", zone_id: zone_2.id}
      assert {:error, changeset} = TaxZone.create(params)

      assert %{
               zone_id: ["Tax Zone with one or more countries in zone already present"]
             } == errors_on(changeset)
    end

    @tag country_count: 3
    test "success if selected zone is mutually exclusive, type country", context do
      zone_1 = insert(:zone, zone_type: "C")
      %{countries: countries} = context
      setup_country_zone_members(zone_1, countries)
      insert(:tax_zone, zone: zone_1)

      zone_2 = insert(:zone, zone_type: "C")
      [countries: new_countries] = countries(%{state_count: 2})
      setup_country_zone_members(zone_2, new_countries)

      params = %{name: "APACzone", zone_id: zone_2.id}
      assert {:ok, _zone} = TaxZone.create(params)
    end
  end

  describe "update/2" do
    @tag country_count: 3
    test "succcessfully", context do
      zone = insert(:zone, zone_type: "C")
      %{countries: countries} = context
      setup_country_zone_members(zone, countries)
      tax_zone = insert(:tax_zone, zone: zone)
      params = %{name: "Pacific"}

      {:ok, updated_zone} = TaxZone.update(tax_zone, params)
      assert updated_zone.id == tax_zone.id
      refute updated_zone.name == tax_zone.name
    end

    @tag country_count: 3
    test "fails if zone set to one associated with another tax zone", context do
      zone_1 = insert(:zone, zone_type: "C")
      %{countries: countries} = context
      setup_country_zone_members(zone_1, countries)
      insert(:tax_zone, zone: zone_1)

      zone_2 = insert(:zone, zone_type: "C")
      [countries: new_countries] = countries(%{state_count: 3})
      setup_country_zone_members(zone_2, new_countries)
      tax_zone = insert(:tax_zone, zone: zone_2)

      params = %{name: "Pacific", zone_id: zone_1.id}

      assert {:error, changeset} = TaxZone.update(tax_zone, params)

      assert %{
               zone_id: ["Tax Zone with one or more countries in zone already present"]
             } == errors_on(changeset)
    end
  end

  describe "get/1" do
    @tag country_count: 3
    test "success", context do
      zone = insert(:zone, zone_type: "C")
      %{countries: countries} = context
      setup_country_zone_members(zone, countries)
      tax_zone = insert(:tax_zone, zone: zone)

      assert {:ok, _country} = TaxZone.get(tax_zone.id)
    end

    test "returns error if not found", context do
      zone = insert(:zone, zone_type: "C")
      %{countries: countries} = context
      setup_country_zone_members(zone, countries)
      insert(:tax_zone, zone: zone)

      assert {:error, message} = TaxZone.get(-1)
      assert message == :tax_zone_not_found
    end
  end

  describe "get_all" do
    @tag country_count: 3
    test "returns a list", context do
      zone = insert(:zone, zone_type: "C")
      %{countries: countries} = context
      setup_country_zone_members(zone, countries)
      insert(:tax_zone, zone: zone)

      assert [_] = TaxZone.get_all()
    end
  end

  @tag country_count: 3
  test "delete a tax zone", context do
    zone = insert(:zone, zone_type: "C")
    %{countries: countries} = context
    setup_country_zone_members(zone, countries)
    tax_zone = insert(:tax_zone, zone: zone)

    assert {:ok, _data} = TaxZone.delete(tax_zone.id)
    assert {:error, message} = TaxZone.get(tax_zone.id)
    assert message == :tax_zone_not_found
  end

  test "get_default tax zone" do
    zone = insert(:zone, zone_type: "C")
    tax_zone = insert(:tax_zone, zone: zone, is_default: true)

    returned_tax_zone = TaxZone.get_default()
    assert returned_tax_zone.id == tax_zone.id
  end

  defp setup_state_zone_members(zone, states) do
    Enum.each(states, fn state ->
      insert(:state_zone_member, zone: zone, state: state)
    end)
  end

  defp setup_country_zone_members(zone, countries) do
    Enum.each(countries, fn country ->
      insert(:country_zone_member, zone: zone, country: country)
    end)
  end
end
