defmodule Snitch.Data.Schema.StateTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase

  import Snitch.Factory

  alias Snitch.Repo
  alias Snitch.Data.Schema.State

  setup :countries

  @valid_attrs %{
    name: "Maharashtra",
    abbr: "MH",
    country_id: 105
  }
  describe "States " do
    test "with valid attributes" do
      %{valid?: validity} = State.changeset(%State{}, @valid_attrs)

      assert validity
    end

    test "with missing abbr" do
      param = Map.delete(@valid_attrs, :abbr)
      c = %{valid?: validity} = State.changeset(%State{}, param)
      refute validity

      assert %{abbr: ["can't be blank"]} = errors_on(c)
    end

    test "with same country_id", %{countries: [country]} do
      param = Map.put(@valid_attrs, :country_id, country.id)
      change = State.changeset(%State{}, param)
      {:ok, changeset} = Repo.insert(change)

      param = Map.put(@valid_attrs, :country_id, changeset.country_id)
      change = State.changeset(%State{}, param)
      {:error, error} = Repo.insert(change)

      assert %{abbr: ["(:country_id, :abbr) has already been taken"]} = errors_on(error)
    end
  end
end
