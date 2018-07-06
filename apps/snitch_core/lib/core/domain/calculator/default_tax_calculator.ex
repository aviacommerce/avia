defmodule Snitch.Domain.Calculator.Default do
  @moduledoc """
  This module provides `compute` function for DefaultCalculator.
  """
  @behaviour Snitch.Domain.Calculator

  alias Snitch.Data.Schema.LineItem

  def compute(tax_rate, %LineItem{} = line_item) do
    total = Money.mult!(line_item.unit_price, line_item.quantity)

    {:ok, value} =
      if tax_rate.included_in_price do
        {:ok, offset} = Money.div(total, 1 + tax_rate.value)
        Money.sub(total, offset)
      else
        Money.mult(total, tax_rate.value)
      end

    value
  end
end
