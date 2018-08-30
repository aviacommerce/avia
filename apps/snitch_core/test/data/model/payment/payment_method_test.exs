defmodule Snitch.Data.Model.PaymentMethodTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase

  import Snitch.Factory

  alias Snitch.Data.Model.PaymentMethod

  test "successful create" do
    params = %{name: "card payment", code: "ccd", provider: CreditCard}
    assert {:ok, ccd} = PaymentMethod.create(params)

    assert %{
             name: "card payment",
             code: "ccd",
             active?: true,
             provider: CreditCard
           } = ccd
  end

  test "create with bad code fails" do
    params = %{name: "card payment", code: "not-a-code", provider: CreditCard}
    assert {:error, changeset} = PaymentMethod.create(params)
    assert %{code: ["should be 3 character(s)"]} = errors_on(changeset)
  end

  describe "with existing" do
    setup :payment_methods

    test "get and update" do
      card_method = PaymentMethod.get_card()
      params = %{id: card_method.id, active?: false, code: "abs", name: "by card"}
      assert {:ok, ccd} = PaymentMethod.update(params)

      assert %{
               name: "by card",
               code: "ccd",
               active?: false
             } = ccd
    end

    test "get and delete" do
      check_method = PaymentMethod.get_check()
      assert {:ok, chk} = PaymentMethod.delete(check_method.id)

      assert %{
               name: "check",
               code: "chk"
             } = chk

      assert nil == PaymentMethod.get_check()
    end

    test "get active payment methods" do
      methods = PaymentMethod.get_active_payment_methods()

      assert length(methods) == 3
    end
  end
end
