defmodule SnitchPayments.PaymentMethodCodesTest do
  use ExUnit.Case
  alias SnitchPayments.PaymentMethodCode

  test "all payment method codes" do
    code = PaymentMethodCode.cash_on_delivery()
    assert code == "cod"
    code = PaymentMethodCode.hosted_payment()
    assert code == "hpm"
    code = PaymentMethodCode.store_credit()
    assert code == "stc"
    code = PaymentMethodCode.credit_card()
    assert code == "ccd"
  end
end
