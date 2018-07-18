defmodule Snitch.Data.Model.CardPaymentTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase

  import Snitch.Factory

  alias Snitch.Data.Model.CardPayment

  setup do
    [
      user: insert(:user),
      order: insert(:order)
    ]
  end

  setup :payment_methods
  setup :cards
  setup :card_payment

  test "create", %{payment: payment} do
    assert payment.state == "some-state"
    assert payment.amount == Money.zero(:USD)
  end

  test "update", %{card_payment: card_payment, payment: payment} do
    card_params = %{cvv_response: "Z", avs_response: "V"}
    payment_params = %{amount: Money.new(-1, :USD), state: "complete"}

    assert {:ok, %{payment: updated_payment, card_payment: updated_card_payment}} =
             CardPayment.update(card_payment, card_params, payment_params)

    assert updated_payment.state == payment_params.state
    assert Money.reduce(updated_payment.amount) == payment.amount
    assert updated_card_payment.cvv_response == card_params.cvv_response
    assert updated_card_payment.avs_response == card_params.avs_response
  end

  defp card_payment(context) do
    %{order: order, cards: [card | _]} = context

    params = %{
      amount: Money.zero(:USD),
      state: "some-state"
    }

    {:ok, %{payment: payment, card_payment: card_payment}} =
      CardPayment.create("card-payment", order.id, params, %{card: Map.from_struct(card)})

    [payment: payment, card_payment: card_payment]
  end
end
