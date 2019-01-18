defmodule Snitch.Data.Model.StateTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase
  alias Snitch.Data.Model.State
  import Snitch.Factory

  setup :states

  describe "get/1 " do
    test "succeeds", %{states: states} do
      states = states |> List.first()
      {:ok, state} = State.get(%{name: "California"})
      assert state.name == states.name
    end

    test "Fails " do
      {:error, msg} = State.get(%{name: "Japan"})
      assert msg == :state_not_found
    end
  end

  describe "get_all/0 " do
    test "succeeds", %{states: states} do
      states_list = State.get_all()
      assert length(states_list) == length(states)
    end
  end

  describe "state formatting " do
    test "for all the states", %{states: states} do
      state = states |> List.first()
      states_list = State.formatted_list()
      assert states_list == [{"California", state.id}]
    end

    test "for states belonging to a given country", %{states: states} do
      state = states |> List.first()
      country_states = State.formatted_state_list(state.country_id)
      assert country_states == [%{id: state.id, text: "California"}]
    end
  end
end
