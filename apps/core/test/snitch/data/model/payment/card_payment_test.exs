defmodule Core.Snitch.Data.Model.CardPaymentMethodTest do
  use ExUnit.Case, async: true
  use Core.DataCase

  alias Core.Snitch.Data.Model

  import Core.Snitch.Factory

  setup :user_with_address
  setup :an_order
  setup :payment_methods
  setup :card_payment

  test "create", context do
    %{payment: payment, order: order} = context
    assert payment.state == "some-state"
    assert payment.amount == order.total
  end

  test "update", context do
    %{card_payment: card_payment, payment: payment} = context
    card_params = %{cvv_response: "Z", avs_response: "V"}
    payment_params = %{amount: Money.new(0, :USD), state: "complete"}

    assert {:ok, %{payment: updated_payment, card_payment: updated_card_payment}} =
             Model.CardPayment.update(card_payment, card_params, payment_params)

    assert updated_payment.state == payment_params.state
    assert Money.reduce(updated_payment.amount) == payment.amount
    assert updated_card_payment.cvv_response == card_params.cvv_response
    assert updated_card_payment.avs_response == card_params.avs_response
  end

  defp card_payment(context) do
    %{order: order} = context
    params = %{amount: order.total, state: "some-state"}

    {:ok, %{payment: payment, card_payment: card_payment}} =
      Model.CardPayment.create("card-payment", order.id, params, %{})

    [payment: payment, card_payment: card_payment]
  end
end
