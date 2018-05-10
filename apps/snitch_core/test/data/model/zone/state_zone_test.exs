defmodule Snitch.Data.Model.StateZoneTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase

  import Snitch.Factory

  alias Snitch.Data.Model.StateZone
  alias Snitch.Data.Schema.{Zone, StateZoneMember}

  setup :states

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
      assert states ==
               zone
               |> StateZone.members()
               |> Enum.map(&Repo.preload(&1, :country))
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

  defp state_zone(%{states: states}) do
    state_ids = Enum.map(states, &Map.get(&1, :id))
    {:ok, zone} = StateZone.create("foo", "bar", state_ids)
    [zone: zone]
  end
end
