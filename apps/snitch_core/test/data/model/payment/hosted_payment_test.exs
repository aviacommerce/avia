defmodule Snitch.Data.Model.HostedPaymentTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase

  import Snitch.Factory

  alias Snitch.Data.Model.HostedPayment
  alias SnitchPayments.PaymentMethodCode

  setup do
    [
      user: insert(:user),
      order: insert(:order)
    ]
  end

  setup :payment_methods
  setup :hosted_payment

  test "create/5 hosted payment and related payment", context do
    %{hosted_method: payment_method} = context
    %{order: order} = context
    payment_params = payment_params()
    hosted_payment_params = hosted_payment_params()
    slug = "hosted-payment" <> to_string(:rand.uniform(1000))
    payment_method_id = payment_method.id
    order_id = order.id

    assert {:ok, %{payment: payment, hosted_payment: hosted_payment}} =
             HostedPayment.create(
               slug,
               order_id,
               payment_params,
               hosted_payment_params,
               payment_method_id
             )

    assert payment.state == "pending"
    assert payment.amount == Money.zero(:USD)
    assert hosted_payment.payment_id == payment.id
  end

  test "update/3", %{hosted_payment: hosted_payment, payment: payment} do
    hosted_params = %{transaction_id: "1234", raw_response: %{status: "success"}}
    payment_params = %{amount: Money.new(-1, :USD), state: "complete"}

    assert {:ok, %{payment: updated_payment, hosted_payment: updated_hosted_payment}} =
             HostedPayment.update(hosted_payment, hosted_params, payment_params)

    assert updated_payment.state == payment_params.state
    assert Money.reduce(updated_payment.amount) == payment.amount
    assert updated_hosted_payment.transaction_id == hosted_params.transaction_id
  end

  defp payment_params() do
    %{
      amount: Money.zero(:USD),
      state: "pending",
      payment_type: PaymentMethodCode.hosted_payment()
    }
  end

  defp hosted_payment_params() do
    %{
      transaction_id: "123abc",
      payment_source: "worldpay"
    }
  end

  defp hosted_payment(context) do
    %{order: order} = context
    %{hosted_method: payment_method} = context

    params = payment_params()
    hosted_params = hosted_payment_params()

    {:ok, %{payment: payment, hosted_payment: hosted_payment}} =
      HostedPayment.create("hosted-payment", order.id, params, hosted_params, payment_method.id)

    [payment: payment, hosted_payment: hosted_payment]
  end
end
