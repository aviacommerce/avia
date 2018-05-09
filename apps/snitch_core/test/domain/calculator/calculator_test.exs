defmodule Snitch.Domain.CalculatorTest do
  use ExUnit.Case, async: true
  import Mox
  alias Snitch.Domain.Calculator

  @error_msg "default 'calculators' not set"
  @error_no_default {:error, @error_msg}

  setup :verify_on_exit!

  test "get all" do
    expect(Snitch.Tools.DefaultsMock, :fetch, fn :calculators ->
      {:ok, [Snitch.Domain.DefaultCalculator]}
    end)

    expect(Snitch.Tools.UserConfigMock, :get, fn :calculators ->
      [FlatRateCalculator, FixRateCalculator]
    end)

    cl = Calculator.list()
    assert length(cl) == 3
  end

  test "when calculator not set in defaults" do
    expect(Snitch.Tools.DefaultsMock, :fetch, fn :calculators ->
      {:error, @error_no_default}
    end)

    assert {:error, msg} = Calculator.list()
    assert msg == @error_no_default
  end
end
