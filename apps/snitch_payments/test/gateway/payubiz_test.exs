defmodule SnitchPayments.Gateway.PayuBizTest do
  use ExUnit.Case
  alias SnitchPayments.Gateway.PayuBiz

  test "credentials/0 returns credentials for payubiz" do
    [key1, key2] = PayuBiz.credentials()
    assert key1 == :merchant_key
    assert key2 == :salt
  end

  test "payment_code/0 returns payment code for payubiz" do
    code = PayuBiz.payment_code()
    assert code == "hpm"
  end
end
