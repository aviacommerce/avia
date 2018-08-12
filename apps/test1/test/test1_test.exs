defmodule Test1Test do
  use ExUnit.Case
  doctest Test1

  test "greets the world" do
    assert Test1.hello() == :world
  end
end
