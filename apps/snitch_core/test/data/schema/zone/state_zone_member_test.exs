defmodule Snitch.Data.Schema.StateZoneMemberTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase

  import Snitch.Factory

  alias Snitch.Data.Schema.StateZoneMember

  setup :states

  describe "StateZoneMember records" do
    test "refer only state type zones", %{states: [state]} do
      state_zone = insert(:zone, zone_type: "S")

      new_state_zone =
        StateZoneMember.create_changeset(%StateZoneMember{state_id: state.id}, %{
          zone_id: state_zone.id
        })

      assert {:ok, _} = Repo.insert(new_state_zone)
    end

    test "don't refer a country zone", %{states: [state]} do
      country_zone = insert(:zone, zone_type: "C")

      new_state_zone =
        StateZoneMember.create_changeset(%StateZoneMember{state_id: state.id}, %{
          zone_id: country_zone.id
        })

      assert {:error, %Ecto.Changeset{errors: errors}} = Repo.insert(new_state_zone)
      assert errors == [zone_id: {"does not refer a state zone", []}]
    end

    test "don't allow duplicate states in a given zone", %{states: [state]} do
      state_zone = insert(:zone, zone_type: "S")

      szm_changset =
        StateZoneMember.create_changeset(%StateZoneMember{state_id: state.id}, %{
          zone_id: state_zone.id
        })

      assert {:ok, _} = Repo.insert(szm_changset)
      assert {:error, cs} = Repo.insert(szm_changset)
      assert %{state_id: ["has already been taken"]} = errors_on(cs)
    end
  end
end
