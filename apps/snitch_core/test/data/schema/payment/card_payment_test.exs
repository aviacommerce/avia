defmodule Snitch.Data.Schema.CardPaymentTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase

  import Snitch.Factory

  alias Snitch.Data.Schema.CardPayment

  setup do
    [
      user: insert(:user),
      order: insert(:order)
    ]
  end

  setup :payment_methods
  setup :payments

  @card %{
    month: 12,
    year: 2099,
    name_on_card: "Tony Stark",
    brand: "VISA",
    number: "4111111111111111",
    card_name: "My VISA card",
    user_id: nil
  }

  describe "CardPayment records" do
    test "refer card type Payments (uniquely)", context do
      %{ccd: card_payment, user: user} = context
      insert(:card_payment, payment_id: card_payment.id)

      card_payment =
        CardPayment.create_changeset(%CardPayment{}, %{
          payment_id: card_payment.id,
          card: %{@card | user_id: user.id}
        })

      assert {:error, cs} = Repo.insert(card_payment)
      assert %{payment_id: ["has already been taken"]} = errors_on(cs)
    end

    test "DON'T refer other Payments", context do
      %{chk: check, user: user} = context

      card_payment =
        CardPayment.create_changeset(%CardPayment{}, %{
          payment_id: check.id,
          card: %{@card | user_id: user.id}
        })

      assert {:error, cs} = Repo.insert(card_payment)
      assert %{payment_id: ["does not refer a card payment"]} = errors_on(cs)
    end
  end

  describe "create" do
    setup :cards

    test "with existing card", %{cards: [card | _], ccd: ccd} do
      card_payment =
        CardPayment.create_changeset(%CardPayment{}, %{
          payment_id: ccd.id,
          card_id: card.id
        })

      assert {:ok, _} = Repo.insert(card_payment)
    end
  end
end
