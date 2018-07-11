defmodule SnitchApiWeb.OrderControllerTest do
  use SnitchApiWeb.ConnCase, async: true
  alias Snitch.Data.Model.Order, as: OrderModel

  setup %{conn: conn} do
    conn =
      conn
      |> put_req_header("accept", "application/vnd.api+json")
      |> put_req_header("content-type", "application/vnd.api+json")

    {:ok, conn: conn}
  end

  test "Empty order creation for guest user", %{conn: conn} do
    conn = post(conn, order_path(conn, :guest_order))
    assert json_response(conn, 200)["data"]
  end
end
