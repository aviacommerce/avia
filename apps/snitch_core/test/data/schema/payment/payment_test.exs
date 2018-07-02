defmodule Snitch.Data.Schema.PaymentTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase

  import Snitch.Factory

  alias Snitch.Data.Schema.Payment

  setup :user_with_address
  setup :an_order
  setup :payment_methods

  test "Payments invalidate bad type", context do
    %{check_method: method, order: order} = context

    check_payment =
      :payment_chk
      |> build(payment_method_id: method.id, order_id: order.id)
      |> Payment.create_changeset(%{payment_type: "abc"})

    assert %Ecto.Changeset{errors: errors} = check_payment
    assert errors == [payment_type: {"is invalid", [validation: :inclusion]}]
  end

  test "Payments cannot have negative amount", context do
    %{check_method: method, order: order} = context

    check_payment =
      :payment_chk
      |> build(payment_method_id: method.id, order_id: order.id)
      |> Payment.create_changeset(%{amount: Money.new("-0.0001", :USD)})

    assert %Ecto.Changeset{errors: errors} = check_payment
    assert errors == [amount: {"must be equal or greater than 0", [validation: :number]}]
  end
end
