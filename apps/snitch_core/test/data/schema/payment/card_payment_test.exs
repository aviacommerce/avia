defmodule Snitch.Data.Schema.CardPaymentTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase

  import Snitch.Factory

  alias Snitch.Data.Schema.{CardPayment, Payment, Order}

  @card %{
    last_digits: "0821",
    month: 12,
    year: 2050,
    name_on_card: "Harry Potter",
    brand: "VISA"
  }

  @payment %Payment{
    slug: "card-payment",
    payment_type: "ccd"
  }

  setup :user_with_address
  setup :an_order
  setup :payment_methods
  setup :payments

  describe "CardPayment records" do
    test "refer card type Payments (uniquely)", context do
      %{ccd: card_payment, user: user} = context

      card_payment =
        CardPayment.changeset(
          %CardPayment{},
          %{payment_id: card_payment.id, card: Map.put(@card, :user_id, user.id)},
          :create
        )

      assert {:error, %{errors: errors}} = Repo.insert(card_payment)
      assert errors == [payment_id: {"has already been taken", []}]
    end

    test "DON'T refer other Payments", context do
      %{chk: check, user: user} = context

      card_payment =
        CardPayment.changeset(
          %CardPayment{},
          %{payment_id: check.id, card: Map.put(@card, :user_id, user.id)},
          :create
        )

      assert {:error, %Ecto.Changeset{errors: errors}} = Repo.insert(card_payment)
      assert errors == [payment_id: {"does not refer a card payment", []}]
    end

    test "when added new card", context do
      %{user: user, card_method: card_m, order: order} = context

      payment_struct = %Payment{@payment | payment_method_id: card_m.id, order_id: order.id}

      payment = insert(payment_struct)

      card_payment =
        CardPayment.changeset(
          %CardPayment{},
          %{payment_id: payment.id, card: Map.put(@card, :user_id, user.id)},
          :create
        )

      %{valid?: validity} = card_payment

      assert validity
      assert {:ok, _} = Repo.insert(card_payment)
    end

    test "with already having card_id", context do
      %{user: user, card_method: card_m, order: order} = context

      payment_struct = %Payment{@payment | payment_method_id: card_m.id, order_id: order.id}

      payment = insert(payment_struct)

      card_payment =
        CardPayment.changeset(
          %CardPayment{},
          %{payment_id: payment.id, card: Map.put(@card, :user_id, user.id)},
          :create
        )

      {:ok, c_payment} = Repo.insert(card_payment)

      order_struct = %Order{
        slug: "order_test",
        state: "cart",
        user_id: user.id
      }

      order = insert(order_struct)

      payment_struct = %Payment{
        @payment
        | payment_method_id: card_m.id,
          order_id: order.id,
          slug: "card-payment_test"
      }

      payment = insert(payment_struct)

      card_payment =
        CardPayment.changeset(
          %CardPayment{},
          %{
            payment_id: payment.id,
            card_id: c_payment.card_id,
            card: Map.put(@card, :user_id, user.id)
          },
          :create
        )

      assert {:ok, _} = Repo.insert(card_payment)
    end
  end
end
