defmodule SnitchPayments.PaymentMethodCode do
  @moduledoc """
  Module to expose payment method codes.

  The module defines and exposes functions for different
  payment methods to keep `codes` related to them uniform
  across the system.

  e.g.
  To access code for credit card
  ```
  iex> PaymentMethodCodes.credit_card()
  iex> "ccd"
  ```
  """
  @credit_card "ccd"
  @hosted_payment "hpm"
  @cash_on_delivery "cod"
  @store_credit "stc"

  def credit_card do
    @credit_card
  end

  def hosted_payment do
    @hosted_payment
  end

  def store_credit do
    @store_credit
  end

  def cash_on_delivery do
    @cash_on_delivery
  end
end
