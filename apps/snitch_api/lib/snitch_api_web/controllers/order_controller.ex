defmodule SnitchApiWeb.OrderController do
  use SnitchApiWeb, :controller

  alias Snitch.Data.Model.Order, as: OrderModel
  alias Snitch.Repo

  def index(conn, params) do
    orders =
      OrderModel.get_all()
      |> Repo.preload(:line_items)

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
end
