defmodule SnitchApiWeb.OrderController do
  use SnitchApiWeb, :controller

  alias Snitch.Data.Model.Order, as: OrderModel
  alias Snitch.Data.Schema.Order
  alias Snitch.Repo

  action_fallback(SnitchApiWeb.FallbackController)
  plug(SnitchApiWeb.Plug.DataToAttributes)
  plug(SnitchApiWeb.Plug.LoadUser)

  def index(conn, params) do
    orders = Repo.preload(OrderModel.get_all(), :line_items)

    render(
      conn,
      "index.json-api",
      data: orders,
      opts: [
        include: params["include"],
        fields: conn.query_params["fields"]
      ]
    )
  end

  def show(conn, %{"id" => id}) do
    order = Snitch.Repo.get!(Order, id)

    render(
      conn,
      "show.json-api",
      data: order
    )
  end

  def guest_order(conn, _params) do
    with {:ok, %Order{} = order} <- OrderModel.create_for_guest(%{}) do
      conn
      |> put_status(200)
      |> put_resp_header("location", order_path(conn, :show, order))
      |> render("show.json-api", data: order)
    end
  end
end
