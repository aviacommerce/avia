defmodule Core.Snitch.Data.Schema.CardPaymentTest do
  use ExUnit.Case, async: true
  use Core.Snitch.Data.Schema

  import Core.Snitch.Factory
  
  setup :checkout_repo
  setup :payment_methods

  describe "CardPayment records" do
    setup [:super_card, :super_check]

    test "refer only card type Payments", context do
      %{super_card: super_card} = context
      card_payment = CardPayment.changeset(%CardPayment{}, %{payment_id: super_card.id}, :create)
      assert {:ok, _} = Core.Repo.insert(card_payment)
    end

    test "DON'T refer other Payments", context do
      %{super_check: super_check} = context
      card_payment = CardPayment.changeset(%CardPayment{}, %{payment_id: super_check.id}, :create)
      Core.Repo.insert(card_payment)
      assert {:error, %Ecto.Changeset{errors: errors}} = Core.Repo.insert(card_payment)
      assert errors == [payment_id: {"does not refer a card payment", []}]
    end
  end

  def payment_methods(context) do
    card = insert(:payment_method_card)
    check = insert(:payment_method_check)

    context
    |> Map.put(:card_method, card)
    |> Map.put(:check_method, check)
  end
  
  defp super_card(%{card_method: method} = context) do
    card = insert(:payment_card, payment_method_id: method.id)
    Map.put(context, :super_card, card)
  end

  defp super_check(%{check_method: method} = context) do
    check = insert(:payment_check, payment_method_id: method.id)
    Map.put(context, :super_check, check)
  end
end

