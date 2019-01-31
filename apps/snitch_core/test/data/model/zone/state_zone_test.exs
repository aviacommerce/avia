defmodule Snitch.Data.Model.StateZoneTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase

  import Snitch.Factory

  alias Ecto.Query
  alias Snitch.Data.Model.StateZone
  alias Snitch.Data.Schema.{StateZoneMember, Zone}

  setup :states
  setup :state_zone
  setup :zones

  @tag state_count: 3
  describe "create/3 and member_ids" do
    test "succeeds with valid state_ids", %{states: states} do
      state_ids = Enum.map(states, &Map.get(&1, :id))
      duplicate_ids = state_ids ++ state_ids
      assert {:ok, zone} = StateZone.create("foo", "bar", duplicate_ids)

      assert state_ids ==
               Repo.all(
                 from(s in StateZoneMember, where: s.zone_id == ^zone.id, select: s.state_id)
               )

      assert state_ids == StateZone.member_ids(zone)
    end

    test "fails if some states are invalid", %{states: states} do
      state_ids = [-1 | Enum.map(states, &Map.get(&1, :id))]
      ordered_state_ids = Enum.reverse(state_ids)

      assert {:error, :members, %{errors: errors}, %{zone: zone}} =
               StateZone.create("foo", "bar", ordered_state_ids)

      assert nil == Repo.get(Zone, zone.id)
      assert errors == [state_id: {"does not exist", []}]
    end
  end

  @tag state_count: 3
  describe "with state_zone" do
    setup :state_zone

    test "members/1 returns State schemas", %{zone: zone, states: states} do
      if Repo.get_prefix() |> is_nil(),
        do:
          assert(
            states ==
              zone
              |> StateZone.members()
              |> Enum.map(&Repo.preload(&1, :country))
          )
    end

    test "delete/1 removes all members too", %{zone: zone} do
      {:ok, _} = StateZone.delete(zone)
      assert [] = StateZone.members(zone)
    end

    test "update/3 succeeds with valid state_ids", %{zone: zone, states: states} do
      more_state_ids = Enum.map(insert_list(2, :state), &Map.get(&1, :id))
      old_state_ids = Enum.map(states, &Map.get(&1, :id))
      new_state_ids = Enum.drop(old_state_ids, 1) ++ more_state_ids
      assert {:ok, _} = StateZone.update(zone, %{}, new_state_ids)
      state_ids = MapSet.new(StateZone.member_ids(zone))

      assert new_state_ids
             |> MapSet.new()
             |> MapSet.equal?(state_ids)
    end

    test "update/3 succeeds with no states", %{zone: zone} do
      assert {:ok, _} = StateZone.update(zone, %{}, [])
      assert [] = StateZone.member_ids(zone)
    end

    test "update/3 fails with invalid states", %{zone: zone} do
      old_state_ids = StateZone.member_ids(zone)

      assert {:error, :added, %{errors: errors}, %{zone: updated_zone}} =
               StateZone.update(zone, %{}, [-1])

      assert errors == [state_id: {"does not exist", []}]
      assert old_state_ids == StateZone.member_ids(updated_zone)
    end
  end

  describe "get/1" do
    test "returns a state_zone using a zone_id", %{zone: zone} do
      {:ok, new_zone} = StateZone.get(zone.id)
      assert new_zone.id == zone.id
    end

    test "fails for invalid id", %{zone: zone} do
      {:error, :zone_not_found} = StateZone.get(-1)
    end
  end

  describe "get_all/0" do
    @tag state_zone_count: 3
    test "returns all state_zones", %{zones: zone} do
      state_zones = StateZone.get_all()
      state_zones = Enum.all?(state_zones, fn x -> x.zone_type == "S" end)
      assert state_zones
    end

    @tag country_zone_count: 3
    test "fails when no state_zone is present", %{zones: zone} do
      state_zones = StateZone.get_all()
      sz_list = List.delete_at(state_zones, 0)
      state_zones = Enum.any?(sz_list, fn x -> x.zone_type == "S" end)
      refute state_zones
    end
  end

  describe "member_changesets/2" do
    test "returns a valid changeset", %{zone: zone, states: states} do
      state_ids = Enum.map(states, &Map.get(&1, :id))
      stream = StateZone.member_changesets(state_ids, zone)
      changeset = Enum.find_value(stream, fn x -> x end)
      assert changeset.valid?
    end

    test "fails to return a valid changeset", %{zone: zone, states: states} do
      state_ids = Enum.map(states, &Map.get(&1, :id))
      zone = Map.put(zone, :id, nil)
      stream = StateZone.member_changesets(state_ids, zone)
      changeset = Enum.find_value(stream, fn x -> x end)
      refute changeset.valid?
      assert %{zone_id: ["can't be blank"]} == errors_on(changeset)
    end
  end

  test "remove_members_query/2 returns a valid query", %{zone: zone, states: states} do
    state_ids = Enum.map(states, &Map.get(&1, :id))

    expected =
      Query.from(c in StateZoneMember,
        where: c.state_id in ^state_ids and c.zone_id == ^zone.id
      )

    result = StateZone.remove_members_query(state_ids, zone)

    assert inspect(result) == inspect(expected)
  end

  @tag state_count: 2
  test "common_zone_query/2 returns a valid query", %{states: states} do
    [state_a_id, state_b_id] = Enum.map(states, fn x -> x.id end)

    expected =
      Query.from(c0 in StateZoneMember,
        join: c1 in StateZoneMember,
        on: true,
        join: z in Zone,
        on: c0.zone_id == c1.zone_id and c0.zone_id == z.id,
        where: c0.state_id == ^state_a_id and c1.state_id == ^state_b_id,
        select: z
      )

    result = StateZone.common_zone_query(state_a_id, state_b_id)

    assert inspect(result) == inspect(expected)
  end

  defp state_zone(%{states: states}) do
    state_ids = Enum.map(states, &Map.get(&1, :id))
    {:ok, zone} = StateZone.create("foo", "bar", state_ids)
    [zone: zone]
  end
end
