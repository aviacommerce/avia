defmodule HelpTest do
  use ExUnit.Case
  doctest Help

  test "greets the world" do
    assert Help.hello() == :world
  end
end
