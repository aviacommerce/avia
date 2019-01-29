defmodule NanoidMock do
  @moduledoc ~S"""
  Mocks upi value producer with a simple counter.
  Initialize with `start_link(0)` to reproduce the following:
  For the first 4 invocations of `get_nano_id` the counter
  will move from 0 to 3 and will always return 0.
  After 4 invocations of `gen_nano_id` (when the counter
  reaches 4) and onwards, it will return a random number.
  """

  use Agent

  # Initialize with a non-negative integer counter.
  def start_link(val) when val >= 0 do
    Agent.start_link(fn -> val end, name: __MODULE__)
  end

  def stop(), do: Agent.stop(__MODULE__)

  def clear(), do: Agent.update(__MODULE__, fn _ -> 0 end)

  def gen_nano_id() do
    new_val = Agent.get_and_update(__MODULE__, fn x -> {x, x + 1} end)

    case div(new_val, 4) do
      0 ->
        0

      _ ->
        :rand.uniform(1_000_000)
    end
  end
end
