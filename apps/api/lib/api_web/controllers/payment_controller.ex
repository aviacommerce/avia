defmodule ApiWeb.PaymentController do
  use ApiWeb, :controller

  alias Snitch.Data.Model.PaymentMethod

  def payment_methods(conn, _params) do
    payment_methods = PaymentMethod.get_all()
    render(conn, "payment_methods.json", payment_methods: payment_methods)
  end
end
