defmodule SnitchApiWeb.PaymentView do
  use SnitchApiWeb, :view
  use JaSerializer.PhoenixView
end

defmodule SnitchApiWeb.PaymentMethodView do
  use SnitchApiWeb, :view
  use JaSerializer.PhoenixView

  location("/payment/payment-methods/:id")

  attributes([
    :name,
    :code,
    :active?,
    :description,
    :live_mode?
  ])
end
