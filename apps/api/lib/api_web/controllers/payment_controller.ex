defmodule ApiWeb.PaymentController do
  use ApiWeb, :controller

  import Ecto.Query, only: [from: 2]

  alias Snitch.Repo
  alias BeepBop.Context
  alias Snitch.Domain.Order.DefaultMachine
  alias Snitch.Data.Schema.PaymentMethod
  alias Snitch.Data.Model.Order
  alias ApiWeb.FallbackController, as: Fallback

  def new(conn, _params) do
    payment_methods = Repo.all(from(pm in PaymentMethod, where: pm.active? == true))
    render(conn, "payment_methods.json", payment_methods: payment_methods)
  end

  def create(conn, %{"payment" => payment_params, "order_id" => id}) do
    %{
      "payment_method_id" => _pm_id,
      "amount" => amount
    } = payment_params

    order = Order.get(%{id: id})

    params = %{
      amount: Money.from_float(amount, order.total.currency)
    }

    context =
      order
      |> Repo.preload(:line_items)
      |> Context.new(state: %{payment_params: params, card_params: nil})
      |> DefaultMachine.add_payment()

    case context do
      %{valid?: true, multi: %{payment: payment}} ->
        render(conn, "payment.json", payment: payment)

      %{valid?: false, multi: errors} ->
        Fallback.call(conn, errors)

      {:error, error} ->
        Fallback.call(conn, {:error, error})
    end
  end
end
