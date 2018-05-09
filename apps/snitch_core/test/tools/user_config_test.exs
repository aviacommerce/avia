defmodule Snitch.Tools.UserConfigTest do
  use ExUnit.Case, async: false
  alias Snitch.Tools.UserConfig

  describe "configured properly" do
    setup do
      Application.put_env(:snitch_core, :foo, [:bar, :baz])

      on_exit(fn ->
        Application.delete_env(:snitch_core, :foo)
      end)
    end

    test "fetch all" do
      assert {:ok, list} = UserConfig.fetch(:foo)
      assert length(list) == 2
    end

    test "get all" do
      list = UserConfig.get(:foo)
      assert length(list) == 2
    end
  end

  describe "not configured properly," do
    test "fetch none return error" do
      assert :error = UserConfig.fetch(:foo)
    end

    test "get none" do
      list = UserConfig.get(:foo)
      assert is_nil(list)
    end
  end
end
