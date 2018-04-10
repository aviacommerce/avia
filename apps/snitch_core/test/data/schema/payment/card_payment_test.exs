defmodule Snitch.Data.Schema.CardPaymentTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase

  import Snitch.Factory

  alias Snitch.Data.Schema.CardPayment

  setup :user_with_address
  setup :an_order
  setup :payment_methods
  setup :card
  setup :payments

  describe "CardPayment records" do
    test "refer card type Payments (uniquely)", context do
      %{ccd: card_payment} = context

      insert(:card_payment, payment_id: card_payment.id)

      card_payment =
        CardPayment.changeset(
          %CardPayment{},
          %{payment_id: card_payment.id, card: Map.from_struct(context.card)},
          :create
        )

      assert {:error, %{errors: errors}} = Repo.insert(card_payment)
      assert errors == [payment_id: {"has already been taken", []}]
    end

    test "DON'T refer other Payments", context do
      %{chk: check} = context

      card_payment =
        CardPayment.changeset(
          %CardPayment{},
          %{payment_id: check.id, card: Map.from_struct(context.card)},
          :create
        )

      assert {:error, %Ecto.Changeset{errors: errors}} = Repo.insert(card_payment)
      assert errors == [payment_id: {"does not refer a card payment", []}]
    end
  end

  describe "create" do
    test "with existing card", context do
      %{card: card, ccd: ccd} = context

      card_payment =
        CardPayment.changeset(
          %CardPayment{},
          %{
            payment_id: ccd.id,
            card_id: card.id
          },
          :create
        )

      assert {:ok, _} = Repo.insert(card_payment)
    end
  end
end
