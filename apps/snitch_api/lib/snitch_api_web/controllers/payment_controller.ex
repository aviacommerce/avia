defmodule SnitchApiWeb.PaymentController do
  use SnitchApiWeb, :controller
  alias Snitch.Data.Model.PaymentMethod
  alias SnitchApiWeb.PaymentMethodView

  def payment_methods(conn, _params) do
    payment_methods = PaymentMethod.get_active_payment_methods()
    render(conn, PaymentMethodView, "index.json-api", data: payment_methods)
  end
end
