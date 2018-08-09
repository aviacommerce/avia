defmodule SnitchPayments.Gateway.PayuBiz do
  @moduledoc """
  Module to expose utilities and functions for the payemnt
  gateway `payubiz`.
  """

  alias SnitchPayments.PaymentMethodCode

  @behaviour SnitchPayments.Gateway

  @credentials [:merchant_key, :salt]

  @doc """
  Returns a list of credentials.

  The `credentials` provided by a `paubiz`
  to a seller on account creation are required while
  performing a transaction.
  """
  @spec credentials() :: list
  def credentials do
    @credentials
  end

  @doc """
  Returns the `payment code` for the gateway.

  The given module implements functionality for
  payubiz as `hosted payment`. The code is returned
  for the same.
  > See
   `SnitchPayments.PaymentMethodCodes`
  """
  @spec payment_code() :: String.t()
  def payment_code do
    PaymentMethodCode.hosted_payment()
  end
end
