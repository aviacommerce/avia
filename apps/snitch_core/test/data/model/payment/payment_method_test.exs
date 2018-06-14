defmodule Snitch.Data.Model.PaymentMethodTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase

  import Snitch.Factory

  alias Snitch.Data.Model.PaymentMethod

  test "successful create" do
    assert {:ok, ccd} = PaymentMethod.create("card-payments", "ccd")

    assert %{
             name: "card-payments",
             code: "ccd",
             active?: true
           } = ccd
  end

  test "create with bad code fails" do
    assert {:error, changeset} = PaymentMethod.create("card-payments", "not-a-code")
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
  end
end
