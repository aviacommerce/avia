defmodule Snitch.Domain.Calculator.DefaultTaxCalculator do
  @moduledoc """
  The default tax calculator module.
  """

  def compute(tax_percent, amount, _included = true) do
    offset =
      amount
      |> Money.mult!(100)
      |> Money.div!(100 + tax_percent)
      |> Money.round(currency_digits: :cash)

    tax_value = Money.sub!(amount, offset)
    %{amount: offset, tax: tax_value}
  end

  def compute(tax_percent, amount, _included = false) do
    tax_value =
      amount
      |> Money.mult!(tax_percent)
      |> Money.div!(100)
      |> Money.round(currency_digits: :cash)

    %{amount: amount, tax: tax_value}
  end
end
