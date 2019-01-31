defmodule Snitch.Data.Schema.StateZoneMemberTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase

  import Snitch.Factory

  alias Snitch.Data.Schema.StateZoneMember

  setup :states

  describe "create_changeset/2" do
    test "successfully for valid params", %{states: [state]} do
      zone = insert(:zone, zone_type: "S")
      params = %{zone_id: zone.id, state_id: state.id}
      cs = StateZoneMember.create_changeset(%StateZoneMember{}, params)
      assert cs.valid?
    end

    test "fails for invalid params" do
      cs = StateZoneMember.create_changeset(%StateZoneMember{}, %{})
      assert %{zone_id: ["can't be blank"], state_id: ["can't be blank"]} == errors_on(cs)
    end
  end

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

  describe "update_changeset/2" do
    setup %{states: [state]} do
      zone = insert(:zone, zone_type: "S")
      params = %{zone_id: zone.id, state_id: state.id}

      [
        cs:
          %StateZoneMember{}
          |> StateZoneMember.create_changeset(params)
          |> apply_changes()
      ]
    end

    test "returns a valid changeset", %{cs: cs} do
      params = %{state_id: 200}
      changeset = StateZoneMember.update_changeset(cs, params)
      assert changeset.valid?
    end

    test "fails for invalid params", %{cs: cs} do
      params = %{state_id: -1}
      changeset = StateZoneMember.update_changeset(cs, params)
      {:error, changeset} = Repo.insert(changeset)
      assert %{state_id: ["does not exist"]} == errors_on(changeset)
    end

    test "fails for duplicate country_id", %{cs: cs} do
      Repo.insert(cs)
      params = %{state_id: cs.state_id}
      changeset = StateZoneMember.update_changeset(cs, params)
      {:error, cs} = Repo.insert(changeset)
      assert %{state_id: ["has already been taken"]} = errors_on(cs)
    end
  end
end
