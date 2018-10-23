defmodule SnitchApiWeb.HostedPaymentView do
  use SnitchApiWeb, :view
  use JaSerializer.PhoenixView

  def render("payubiz-url.json-api", %{url: url}) do
    %{url: url}
  end

  def render("payubiz-url.json-api", %{error: message}) do
    %{error: message}
  end

  def render("stripe.json-api", %{publishable_key: key}) do
    %{publishable_key: key}
  end

  def render("payment_failure.json-api", %{order: order, reason: reason}) do
    %{
      error: %{
        order_number: order.number,
        reason: reason
      }
    }
  end
end
