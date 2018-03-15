defmodule Snitch.Data.Model.PaymentMethodTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase

  import Snitch.Factory

  alias Snitch.Data.{Schema, Model}

  test "successful create" do
    assert {:ok, ccd} = Model.PaymentMethod.create("card-payments", "ccd")

    assert %Schema.PaymentMethod{
             name: "card-payments",
             code: "ccd",
             active?: true
           } = ccd
  end

  test "create with bad code fails" do
    assert {:error, changeset} = Model.PaymentMethod.create("card-payments", "not-a-code")
    assert %{code: ["should be 3 character(s)"]} = errors_on(changeset)
  end

  describe "with existing" do
    setup :payment_methods

    test "get and update" do
      card_method = Model.PaymentMethod.get_card()
      params = %{id: card_method.id, active?: false, code: "abs", name: "by card"}
      assert {:ok, ccd} = Model.PaymentMethod.update(params)

      assert %Schema.PaymentMethod{
               name: "by card",
               code: "ccd",
               active?: false
             } = ccd
    end

    test "get and delete" do
      check_method = Model.PaymentMethod.get_check()
      assert {:ok, chk} = Model.PaymentMethod.delete(check_method.id)

      assert %Schema.PaymentMethod{
               name: "check",
               code: "chk"
             } = chk

      assert nil == Model.PaymentMethod.get_check()
    end
  end
end
