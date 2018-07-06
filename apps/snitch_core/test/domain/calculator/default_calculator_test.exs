defmodule Snitch.Domain.DefaultCalculatorTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase

  alias Snitch.Domain.Calculator.Default, as: DefaultCalculator
  alias Snitch.Data.Schema.LineItem

  @tax_info %{
    value: 0.5,
    included_in_price: false
  }

  @lineitem %LineItem{
    order_id: 1,
    variant_id: 1,
    quantity: 1,
    unit_price: Money.new("15.00", :USD)
  }

  describe "compute/2" do
    test "tax, isn't included in price" do
      assert value = %Money{} = DefaultCalculator.compute(@tax_info, @lineitem)
      # total price = 15.00
      # tax rate = 0.5
      # tax_value = 15. 00 * 0.5 = 7.50
      assert Money.equal?(value, Money.new("7.50", :USD))
    end

    test "tax, is included in price" do
      tax_info = %{@tax_info | included_in_price: true}
      assert value = %Money{} = DefaultCalculator.compute(tax_info, @lineitem)
      # total price = 15.00
      # tax rate = 0.5
      # tax_value = 15.00 - ((15.00/1+0.5) = 5.00 = 5.00
      assert Money.equal?(value, Money.new("5.00", :USD))
    end
  end
end
