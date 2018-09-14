defmodule SnitchApiWeb.PaymentController do
  use SnitchApiWeb, :controller
  alias SnitchApi.CodPayment
  alias SnitchApiWeb.OrderView
  alias Snitch.Data.Model.PaymentMethod
  alias SnitchApiWeb.PaymentMethodView

  action_fallback(SnitchApiWeb.FallbackController)
  plug(SnitchApiWeb.Plug.DataToAttributes)
  plug(SnitchApiWeb.Plug.LoadUser)

  def payment_methods(conn, _params) do
    payment_methods = PaymentMethod.get_active_payment_methods()
    render(conn, PaymentMethodView, "index.json-api", data: payment_methods)
  end

  def cod_payment(conn, %{"order_id" => order_id}) do
    with {:ok, order} <- CodPayment.make_payment(order_id) do
      render(
        conn,
        OrderView,
        "show.json-api",
        data: order
      )
    end
  end
end
