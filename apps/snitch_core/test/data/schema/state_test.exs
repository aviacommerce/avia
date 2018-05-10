defmodule Snitch.Data.Schema.StateTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase

  import Snitch.Factory

  alias Snitch.Data.Schema.State

  setup :countries

  @valid_attrs %{
    name: "Maharashtra",
    code: "IN-MH",
    country_id: 105
  }
  describe "States " do
    test "with valid attributes" do
      %{valid?: validity} = State.changeset(%State{}, @valid_attrs)

      assert validity
    end

    test "with missing code" do
      param = Map.delete(@valid_attrs, :code)
      c = %{valid?: validity} = State.changeset(%State{}, param)
      refute validity

      assert %{code: ["can't be blank"]} = errors_on(c)
    end
  end
end
