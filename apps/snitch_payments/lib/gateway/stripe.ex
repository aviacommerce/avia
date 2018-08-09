defmodule SnitchPayments.Gateway.Stripe do
  @moduledoc """
  Module to expose utilities and functions for the payemnt
  gateway `stripe`.
  """
  alias SnitchPayments.PaymentMethodCode

  @behaviour SnitchPayments.Gateway
  @credentials [:secret_key]

  @doc """
  Returns a list of credentials.

  The `credentials` provided by a `stripe`
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
  stripe as `hosted payment`. The code is returned
  for the same.
  > See
   `SnitchPayments.PaymentMethodCodes`
  """
  def payment_code do
    PaymentMethodCode.hosted_payment()
  end
end
