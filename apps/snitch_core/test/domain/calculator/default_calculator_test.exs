defmodule Snitch.Domain.DefaultCalculatorTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase

  alias Snitch.Domain.Calculator.DefaultTaxCalculator

  @tax_percent 50
  @amount Money.new!(:USD, 15)

  describe "compute/2" do
    test "tax, isn't included in price" do
      assert %{amount: amount, tax: tax} =
               DefaultTaxCalculator.compute(@tax_percent, @amount, _included = false)

      # total price = 15.00
      # tax rate = 0.5
      # tax_value = 15. 00 * 0.5 = 7.50
      assert Money.equal?(tax, Money.new(:USD, "7.50"))
    end

    test "tax, is included in price" do
      assert %{amount: amount, tax: tax} =
               DefaultTaxCalculator.compute(@tax_percent, @amount, _included = true)

      # total price = 15.00
      # tax rate = 50
      # tax_value = 15.00 - ((15.00/1+0.5) = 5.00 = 5.00
      assert Money.equal?(tax, Money.new("5.00", :USD))
    end
  end
end
