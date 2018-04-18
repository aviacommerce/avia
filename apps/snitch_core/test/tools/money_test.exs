defmodule Snitch.Tools.MoneyTest do
  use ExUnit.Case, async: true

  alias Snitch.Tools.Money, as: MoneyTools

  @usd Money.new(0, :USD)
  @inr Money.new(0, :INR)
  @msg_currency "The currency :AAA is invalid"
  @msg_no_default "default currency not set"
  @error_currency {:error, {Money.UnknownCurrencyError, @msg_currency}}
  @error_no_default {:error, {RuntimeError, @msg_no_default}}

  setup_all do
    Application.put_env(:snitch_core, :core_config_app, :snitch)
  end

  describe "when configured all right" do
    setup do
      Application.put_env(:snitch, :defaults, currency: :USD)
    end

    test "zero/1" do
      assert @usd == MoneyTools.zero()
      assert @inr == MoneyTools.zero(:INR)
      assert @error_currency = MoneyTools.zero(:AAA)
    end

    test "zero!/1" do
      assert @usd == MoneyTools.zero!()
      assert @inr == MoneyTools.zero!(:INR)

      assert_raise Money.UnknownCurrencyError, @msg_currency, fn ->
        MoneyTools.zero!(:AAA)
      end
    end
  end

  describe "when no default currency" do
    setup do
      Application.put_env(:snitch, :defaults, [])
    end

    test "zero/1" do
      assert @inr == MoneyTools.zero(:INR)
      assert @error_no_default = MoneyTools.zero()
      assert @error_currency = MoneyTools.zero(:AAA)
    end

    test "zero!/1" do
      assert @inr == MoneyTools.zero!(:INR)

      assert_raise RuntimeError, @msg_no_default, fn ->
        MoneyTools.zero!()
      end

      assert_raise Money.UnknownCurrencyError, @msg_currency, fn ->
        MoneyTools.zero!(:AAA)
      end
    end
  end
end
