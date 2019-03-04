defmodule Snitch.Data.Schema.PaymentTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase

  import Snitch.Factory

  alias Snitch.Data.Schema.Payment

  setup do
    [order: insert(:order)]
  end

  setup :payment_methods

  test "Payments invalidate bad type", %{check_method: method, order: order} do
    check_payment =
      :payment_chk
      |> build(payment_method_id: method.id, order_id: order.id)
      |> Payment.create_changeset(%{payment_type: "abc"})

    assert %{payment_type: ["is invalid"]} == errors_on(check_payment)
  end

  test "Payments cannot have negative amount", %{check_method: method, order: order} do
    check_payment =
      :payment_chk
      |> build(payment_method_id: method.id, order_id: order.id)
      |> Payment.create_changeset(%{amount: Money.new("-0.0001", :USD)})

    assert %{amount: ["must be equal or greater than 0"]} == errors_on(check_payment)
  end
end
