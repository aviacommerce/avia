defmodule Core.Snitch.Data.Schema.CardPaymentTest do
  use ExUnit.Case, async: true
  use Core.DataCase

  import Core.Snitch.Factory

  alias Core.Snitch.Data.Schema.CardPayment

  setup :user_with_address
  setup :an_order
  setup :payment_methods
  setup :payments

  describe "CardPayment records" do
    test "refer card type Payments (uniquely)", context do
      %{ccd: card} = context
      card_payment = CardPayment.changeset(%CardPayment{}, %{payment_id: card.id}, :create)
      assert {:error, %{errors: errors}} = Core.Repo.insert(card_payment)
      assert errors == [payment_id: {"has already been taken", []}]
    end

    test "DON'T refer other Payments", context do
      %{chk: check} = context
      card_payment = CardPayment.changeset(%CardPayment{}, %{payment_id: check.id}, :create)
      Core.Repo.insert(card_payment)
      assert {:error, %Ecto.Changeset{errors: errors}} = Core.Repo.insert(card_payment)
      assert errors == [payment_id: {"does not refer a card payment", []}]
    end
  end
end
