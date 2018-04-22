defmodule Snitch.Tools.MoneyTest do
  use ExUnit.Case, async: true

  alias Snitch.Tools.Money, as: MoneyTools

  import Mox

  @msg_no_default "default 'currency' not set"
  @error_no_default {:error, @msg_no_default}

  setup :verify_on_exit!

  test "when configured all right zero/0, zero!/0" do
    expect(Snitch.Tools.DefaultsMock, :fetch, 2, fn :currency -> {:ok, :INR} end)

    assert Money.zero(:INR) == MoneyTools.zero()
    assert Money.zero(:INR) == MoneyTools.zero!()
  end

  test "when no default currency zero/0, zero!/0" do
    expect(Snitch.Tools.DefaultsMock, :fetch, 2, fn :currency -> @error_no_default end)

    assert @error_no_default = MoneyTools.zero()

    assert_raise RuntimeError, @msg_no_default, fn ->
      MoneyTools.zero!()
    end
  end

  test "zero/1, and zero!/1" do
    assert MoneyTools.zero(:USD) == Money.zero(:USD)
    assert MoneyTools.zero(:ZZZ) == Money.zero(:ZZZ)

    assert MoneyTools.zero!(:USD) == Money.zero(:USD)

    assert_raise Money.UnknownCurrencyError, "The currency :ZZZ is invalid", fn ->
      MoneyTools.zero!(:ZZZ)
    end
  end
end
