defmodule ApiWeb.PaymentController do
  use ApiWeb, :controller

  import Ecto.Query, only: [from: 2]

  alias Snitch.Repo
  alias Snitch.Data.Schema.PaymentMethod

  def new(conn, _params) do
    payment_methods = Repo.all(from(pm in PaymentMethod, where: pm.active? == true))
    render(conn, "payment_methods.json", payment_methods: payment_methods)
  end
end
