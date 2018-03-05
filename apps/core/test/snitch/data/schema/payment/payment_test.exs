defmodule Core.Snitch.Data.Schema.PaymentTest do
  use ExUnit.Case, async: true
  use Core.Snitch.Data.Schema

  import Core.Snitch.Factory

  setup :checkout_repo
  setup :user_with_address
  setup :an_order
  setup :payment_methods

  test "Payments invalidate bad type", context do
    %{check_method: method, order: order} = context

    check_payment =
      :payment_chk
      |> build(payment_type: "abc", payment_method_id: method.id, order_id: order.id)
      |> Payment.changeset(%{}, :create)

    assert %Ecto.Changeset{errors: errors} = check_payment
    assert errors == [payment_type: {"'abc' is invalid", [validation: :inclusion]}]
  end

  test "Payments cannot have negative amount", context do
    %{check_method: method, order: order} = context

    check_payment =
      :payment_chk
      |> build(payment_method_id: method.id, order_id: order.id)
      |> Payment.changeset(%{amount: Money.new("-0.0001", :USD)}, :create)

    assert %Ecto.Changeset{errors: errors} = check_payment
    assert errors == [amount: {"must be greater than 0", [validation: :amount]}]
  end
end
