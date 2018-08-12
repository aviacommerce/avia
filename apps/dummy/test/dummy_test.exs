defmodule DummyTest do
  use ExUnit.Case
  doctest Dummy

  test "greets the world" do
    assert Dummy.hello() == :world
  end
end
