defmodule SnitchPaymentsTest do
  use ExUnit.Case
  alias SnitchPayments
  doctest SnitchPayments

  test "list all payment methods" do
    list = SnitchPayments.payment_providers()
    assert length(list) == 2
  end
end
