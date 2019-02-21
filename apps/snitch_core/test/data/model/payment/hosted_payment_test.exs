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

  describe "create/5" do
    test "creates hosted payment and related payment successfully", context do
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

    test "fails for non_existent order_id", context do
      %{hosted_method: payment_method} = context
      %{order: order} = context
      payment_params = payment_params()
      hosted_payment_params = hosted_payment_params()
      slug = "hosted-payment" <> to_string(:rand.uniform(1000))
      payment_method_id = payment_method.id
      order_id = -1

      {:error, changeset} =
        HostedPayment.create(
          slug,
          order_id,
          payment_params,
          hosted_payment_params,
          payment_method_id
        )

      assert %{order_id: ["does not exist"]} == errors_on(changeset)
    end

    test "fails for duplicate slug", context do
      %{hosted_method: payment_method} = context
      %{order: order} = context
      payment_params = payment_params()
      hosted_payment_params = hosted_payment_params()
      slug = "hosted-payment" <> to_string(:rand.uniform(1000))
      payment_method_id = payment_method.id
      order_id = order.id

      {:ok, _} =
        HostedPayment.create(
          slug,
          order_id,
          payment_params,
          hosted_payment_params,
          payment_method_id
        )

      {:error, changeset} =
        HostedPayment.create(
          slug,
          order_id,
          payment_params,
          hosted_payment_params,
          payment_method_id
        )

      assert %{slug: ["has already been taken"]} == errors_on(changeset)
    end
  end

  describe "update/3" do
    test "updates hosted_payment and related_payment successfully", %{
      hosted_payment: hosted_payment,
      payment: payment
    } do
      hosted_params = %{transaction_id: "1234", raw_response: %{status: "success"}}
      payment_params = %{amount: Money.new(-1, :USD), state: "complete"}

      assert {:ok, %{payment: updated_payment, hosted_payment: updated_hosted_payment}} =
               HostedPayment.update(hosted_payment, hosted_params, payment_params)

      assert updated_payment.state == payment_params.state
      assert Money.reduce(updated_payment.amount) == payment.amount
      assert updated_hosted_payment.transaction_id == hosted_params.transaction_id
    end

    test "fails for invalid transaction_id and payment_source", %{
      hosted_payment: hosted_payment,
      payment: payment
    } do
      hosted_params = %{transaction_id: 10, payment_source: 20}
      {:error, changeset} = HostedPayment.update(hosted_payment, hosted_params, payment_params)
      assert %{transaction_id: ["is invalid"], payment_source: ["is invalid"]}
    end
  end

  describe "get/1" do
    test "returns a hosted payment with valid id", %{hosted_payment: hosted_payment} do
      {:ok, returned_hosted_payment} = HostedPayment.get(hosted_payment.id)
      assert hosted_payment.id == returned_hosted_payment.id
    end

    test "fails for invalid id" do
      assert {:error, :hosted_payment_not_found} = HostedPayment.get(-1)
    end

    test "returns a hosted payment with  query params", %{hosted_payment: hosted_payment} do
      map = %{payment_id: hosted_payment.payment_id}
      {:ok, returned_hosted_payment} = HostedPayment.get(map)
      assert returned_hosted_payment.id == hosted_payment.id
    end
  end

  test "get_all/0", %{hosted_payment: hosted_payment, payment: payment} do
    returned_hosted_payments = HostedPayment.get_all()
    assert returned_hosted_payments != []
  end

  test "from_payment/1 returns a hosted payment", %{hosted_payment: hosted_payment} do
    id = hosted_payment.payment_id
    returned_hosted_payment = HostedPayment.from_payment(id)
    assert returned_hosted_payment.id == hosted_payment.id
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
