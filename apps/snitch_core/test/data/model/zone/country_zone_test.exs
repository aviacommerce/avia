defmodule Snitch.Data.Model.CountryZoneTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase

  import Snitch.Factory

  alias Ecto.Query
  alias Snitch.Data.Model.CountryZone
  alias Snitch.Data.Schema.{CountryZoneMember, Zone}

  setup :countries
  setup :country_zone
  setup :zones

  @tag country_count: 3
  describe "create/3 and member_ids" do
    test "succeeds with valid country_ids", %{countries: countries} do
      country_ids = Enum.map(countries, &Map.get(&1, :id))
      duplicate_ids = country_ids ++ country_ids
      assert {:ok, zone} = CountryZone.create("foo", "bar", duplicate_ids)

      assert country_ids ==
               Repo.all(
                 from(c in CountryZoneMember, where: c.zone_id == ^zone.id, select: c.country_id)
               )

      assert country_ids == CountryZone.member_ids(zone)
    end

    test "fails if some states are invalid", %{countries: countries} do
      country_ids = [-1 | Enum.map(countries, &Map.get(&1, :id))]
      ordered_country_ids = Enum.reverse(country_ids)

      assert {:error, :members, %{errors: errors}, %{zone: zone}} =
               CountryZone.create("foo", "bar", ordered_country_ids)

      assert nil == Repo.get(Zone, zone.id)
      assert errors == [country_id: {"does not exist", []}]
    end
  end

  @tag country_count: 3
  describe "with country_zone" do
    setup :country_zone

    test "members/1 returns Country schemas", %{zone: zone, countries: countries} do
      assert countries == CountryZone.members(zone)
    end

    test "delete/1 removes all members too", %{zone: zone} do
      {:ok, _} = CountryZone.delete(zone)
      assert [] = CountryZone.members(zone)
    end

    test "update/3 succeeds with valid country_ids", %{zone: zone, countries: countries} do
      more_country_ids = Enum.map(insert_list(2, :country), &Map.get(&1, :id))
      old_country_ids = Enum.map(countries, &Map.get(&1, :id))
      new_country_ids = Enum.drop(old_country_ids, 1) ++ more_country_ids
      assert {:ok, _} = CountryZone.update(zone, %{}, new_country_ids)
      country_ids = MapSet.new(CountryZone.member_ids(zone))

      assert new_country_ids
             |> MapSet.new()
             |> MapSet.equal?(country_ids)
    end

    test "update/3 succeeds with no states", %{zone: zone} do
      assert {:ok, _} = CountryZone.update(zone, %{}, [])
      assert [] = CountryZone.member_ids(zone)
    end

    test "update/3 fails with invalid states", %{zone: zone} do
      old_country_ids = CountryZone.member_ids(zone)

      assert {:error, :added, %{errors: errors}, %{zone: updated_zone}} =
               CountryZone.update(zone, %{}, [-1])

      assert errors == [country_id: {"does not exist", []}]
      assert old_country_ids == CountryZone.member_ids(updated_zone)
    end
  end

  describe "get/1" do
    test "returns a zone using a zone_id", %{zone: zone} do
      {:ok, new_zone} = CountryZone.get(zone.id)
      assert new_zone.id == zone.id
    end

    test "fails for invalid id", %{zone: zone} do
      assert {:error, :zone_not_found} = CountryZone.get(-1)
    end
  end

  describe "get_all/0" do
    @tag country_zone_count: 3
    test "returns all zones", %{zones: zone} do
      country_zones = CountryZone.get_all()
      country_zones = Enum.all?(country_zones, fn x -> x.zone_type == "C" end)
      assert country_zones
    end

    @tag state_zone_count: 3
    test "fails when no country_zone is present", %{zones: zone} do
      country_zones = CountryZone.get_all()
      cz_list = List.delete_at(country_zones, 0)
      country_zones = Enum.any?(cz_list, fn x -> x.zone_type == "C" end)
      refute country_zones
    end
  end

  describe "member_changesets/2" do
    test "returns a valid changeset", %{zone: zone, countries: countries} do
      country_ids = Enum.map(countries, &Map.get(&1, :id))
      stream = CountryZone.member_changesets(country_ids, zone)
      changeset = Enum.find_value(stream, fn x -> x end)
      assert changeset.valid?
    end

    test "fails to return a valid changeset", %{zone: zone, countries: countries} do
      country_ids = Enum.map(countries, &Map.get(&1, :id))
      zone = Map.put(zone, :id, nil)
      stream = CountryZone.member_changesets(country_ids, zone)
      changeset = Enum.find_value(stream, fn x -> x end)
      refute changeset.valid?
      assert %{zone_id: ["can't be blank"]} == errors_on(changeset)
    end
  end

  test "remove_members_query/2 returns a valid query", %{zone: zone, countries: countries} do
    country_ids = Enum.map(countries, &Map.get(&1, :id))

    expected =
      Query.from(c in CountryZoneMember,
        where: c.country_id in ^country_ids and c.zone_id == ^zone.id
      )

    result = CountryZone.remove_members_query(country_ids, zone)

    assert inspect(result) == inspect(expected)
  end

  @tag country_count: 2
  test "common_zone_query/2 returns a valid query", %{countries: countries} do
    [country_a_id, country_b_id] = Enum.map(countries, fn x -> x.id end)

    expected =
      Query.from(c0 in CountryZoneMember,
        join: c1 in CountryZoneMember,
        on: true,
        join: z in Zone,
        on: c0.zone_id == c1.zone_id and c0.zone_id == z.id,
        where: c0.country_id == ^country_a_id and c1.country_id == ^country_b_id,
        select: z
      )

    result = CountryZone.common_zone_query(country_a_id, country_b_id)

    assert inspect(result) == inspect(expected)
  end

  defp country_zone(%{countries: countries}) do
    country_ids = Enum.map(countries, &Map.get(&1, :id))
    {:ok, zone} = CountryZone.create("foo", "bar", country_ids)
    [zone: zone]
  end
end
