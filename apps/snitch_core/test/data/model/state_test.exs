defmodule Snitch.Data.Model.StateTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase
  alias Snitch.Data.Model.State
  import Snitch.Factory

  setup :states

  describe "state formatting" do
    test "for all the states", %{states: states} do
      state = states |> List.first()
      states_list = State.formatted_list()
      assert states_list == [{"California", state.id}]
    end

    test "for all the states belonging to a given country", %{states: states} do
      state = states |> List.first()
      country_states = State.formatted_state_list(state.country_id)
      assert country_states == [%{id: state.id, text: "California"}]
    end
  end
end
