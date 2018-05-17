defmodule Snitch.Data.Model.CountryZoneTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase

  import Snitch.Factory

  alias Snitch.Data.Model.CountryZone
  alias Snitch.Data.Schema.{Zone, CountryZoneMember}

  setup :countries

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

  defp country_zone(%{countries: countries}) do
    country_ids = Enum.map(countries, &Map.get(&1, :id))
    {:ok, zone} = CountryZone.create("foo", "bar", country_ids)
    [zone: zone]
  end
end
