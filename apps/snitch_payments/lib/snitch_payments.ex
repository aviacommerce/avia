defmodule SnitchPayments do
  @moduledoc """
  Documentation for `SnitchPayments`.
  """

  def payment_providers do
    with {:ok, list} = :application.get_key(:snitch_payments, :modules) do
      list
      |> Enum.filter(&(length(&1 |> Module.split()) >= 3))
      |> Enum.map(fn gateway ->
        [hd | _] =
          gateway
          |> Atom.to_string()
          |> String.split(".")
          |> Enum.reverse()

        {hd, gateway}
      end)
    end
  end
end
