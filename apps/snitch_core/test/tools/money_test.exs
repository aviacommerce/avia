defmodule Snitch.Tools.MoneyTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase

  import Mox
  import Snitch.Factory

  alias Snitch.Tools.Money, as: MoneyTools
  alias Snitch.Data.Model.GeneralConfiguration, as: GCModel

  setup :verify_on_exit!

  test "when configured all right zero/0, zero!/0" do
    config = insert(:general_config)

    assert Money.zero(config.currency) == MoneyTools.zero()
    assert Money.zero(config.currency) == MoneyTools.zero!()
  end

  test "when no default currency zero/0, zero!/0" do
    currency = GCModel.fetch_currency()

    assert Money.zero(currency) == MoneyTools.zero()
    assert Money.zero(currency) == MoneyTools.zero!()
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
