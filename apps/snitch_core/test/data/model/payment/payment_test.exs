defmodule Snitch.Data.Model.PaymentTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase

  import Snitch.Factory

  alias Snitch.Data.Model.Payment
  alias Snitch.Data.Schema

  setup do
    [
      order: insert(:order)
    ]
  end

  setup :payment_methods
  setup :payments

  test "to_subtype", %{ccd: card, chk: check} do
    insert(:card_payment, payment_id: card.id)
    assert %Schema.CardPayment{} = Payment.to_subtype(card.id)
    assert %Schema.Payment{} = Payment.to_subtype(check.id)
  end

  test "payment count by date", %{ccd: card, chk: check} do
    payment =
      insert(:payment_ccd, payment_method_id: card.payment_method_id, order_id: card.order_id)

    next_date =
      payment.inserted_at
      |> NaiveDateTime.to_date()
      |> Date.add(1)
      |> Date.to_string()
      |> get_naive_date_time()

    payment_date_count =
      Payment.get_payment_count_by_date(payment.inserted_at, next_date) |> List.first()

    assert %Money{} = payment_date_count.count
  end

  test "get_all/0 return all payments", %{ccd: cod, chk: check, hpm: hosted_payment} do
    returned_payments = Payment.get_all()
    assert returned_payments != []
  end

  test "delete/1 deletes a payment", %{hpm: payment} do
    {:ok, cs} = Payment.delete(payment)
    assert Payment.get(payment.id) == {:error, :payment_not_found}
  end

  defp get_naive_date_time(date) do
    Date.from_iso8601(date)
    |> elem(1)
    |> NaiveDateTime.new(~T[00:00:00])
    |> elem(1)
  end
end
