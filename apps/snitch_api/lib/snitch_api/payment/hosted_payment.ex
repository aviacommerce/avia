defmodule SnitchApi.Payment.HostedPayment do
  @moduledoc """
  Utilites for hosted payments.
  """

  alias BeepBop.Context
  alias Snitch.Data.Model.HostedPayment
  alias Snitch.Data.Model.Order
  alias Snitch.Data.Model.Payment
  alias Snitch.Data.Model.PaymentMethod
  alias Snitch.Domain.Order.DefaultMachine
  alias Snitch.Core.Tools.MultiTenancy.Repo

  def payment_order_context(%{status: "success"} = params) do
    payment_params = %{state: "paid"}

    case update_hosted_payment(params, payment_params) do
      {:ok, order, _} ->
        context = Context.new(order, state: %{})
        transition = DefaultMachine.confirm_purchase_payment(context)
        transition_response(transition)

      {:error, message} = error ->
        {:error, %{message: message}}
    end
  end

  def payment_order_context(%{status: "failure"} = params) do
    payment_params = %{state: "failed"}

    case update_hosted_payment(params, payment_params) do
      {:ok, order, _} ->
        {:ok, order}

      {:error, message} = error ->
        {:error, %{message: params.error_reason <> ", " <> message}}
    end
  end

  def get_payment_preferences(payment_method_id) do
    {:ok, payment_method} = PaymentMethod.get(payment_method_id)
    credentials = payment_method.preferences()
    live_mode = payment_method.live_mode?
    %{credentials: credentials, live_mode: live_mode}
  end

  # TODO Check extra query fired for getting payment record
  #     after update should use the returned payment.
  defp update_hosted_payment(params, payment_params) do
    order_id = params.order_id
    payment_id = params.payment_id
    transaction_id = params.transaction_id
    payment_source = params.payment_source
    raw_response = params.raw_response
    hosted_payment = HostedPayment.from_payment(payment_id)

    hosted_params = %{
      transaction_id: transaction_id,
      payment_source: payment_source,
      raw_response: raw_response
    }

    with {:ok, %{hosted_payment: hosted_payment}} <-
           HostedPayment.update(hosted_payment, hosted_params, payment_params),
         {:ok, order} <- Order.get(order_id) do
      order = order |> Repo.preload(:user)
      {:ok, payment} = Payment.get(hosted_payment.payment_id)
      {:ok, order, payment}
    else
      {:error, :order_not_found} -> {:error, "Order not found"}
      {:error, _} -> {:error, "some error occured"}
    end
  end

  defp transition_response(%Context{errors: nil, struct: order}) do
    {:ok, order}
  end

  defp transition_response(%Context{errors: errors}, _) do
    {:error, message} = errors
    {:error, %{message: message}}
  end
end
