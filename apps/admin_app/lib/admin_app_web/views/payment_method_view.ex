defmodule AdminAppWeb.PaymentMethodView do
  use AdminAppWeb, :view
  alias SnitchPayments

  def capitalize(data) when is_atom(data) do
    data
    |> Atom.to_string()
    |> String.capitalize()
  end

  def capitalize(data) do
    data
    |> String.capitalize()
  end

  def providers() do
    SnitchPayments.payment_providers()
  end
end
