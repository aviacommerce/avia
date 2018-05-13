defmodule Snitch.Tools.DefaultsTest do
  use ExUnit.Case, async: false

  alias Snitch.Tools.Defaults

  describe "when configured all right" do
    setup do
      Application.put_env(:snitch_core, :defaults, currency: :USD, foo: :bar)

      on_exit(fn ->
        Application.delete_env(:snitch_core, :defaults)
      end)
    end

    test "validate_config/1" do
      assert :ok = Defaults.validate_config()
    end

    test "and key is set" do
      assert {:ok, :USD} = Defaults.fetch(:currency)
      assert {:ok, :bar} = Defaults.fetch(:foo)
    end

    test "and key is not set" do
      assert {:error, "default 'baz' not set"} = Defaults.fetch(:baz)
    end
  end

  describe "fetch" do
    test "when no defaults" do
      Application.delete_env(:snitch_core, :defaults)
      assert {:error, "Could not fetch any 'defaults'"} = Defaults.fetch(:currency)
    end
  end
end
