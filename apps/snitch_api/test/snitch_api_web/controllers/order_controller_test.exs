defmodule SnitchApiWeb.OrderControllerTest do
  use SnitchApiWeb.ConnCase, async: true
  import Snitch.Factory

  alias SnitchApi.Accounts
  alias Snitch.Repo
  alias Snitch.Data.Model.Order, as: OrderModel

  setup %{conn: conn} do
    insert(:role, name: "user")
    user = build(:user_with_no_role)

    conn =
      conn
      |> put_req_header("accept", "application/vnd.api+json")
      |> put_req_header("content-type", "application/vnd.api+json")

    {:ok, registered_user} = Accounts.create_user(user)
    {:ok, token, _claims} = SnitchApi.Guardian.encode_and_sign(registered_user)
    {:ok, conn: conn, token: token}
  end

  test "Empty order creation for guest user", %{conn: conn} do
    conn = post(conn, order_path(conn, :guest_order))
    assert json_response(conn, 200)["data"]
  end

  describe "user orders" do
    test "unauthenticated user", %{conn: conn} do
      resp = get(conn, order_path(conn, :index))
      assert resp.status == 403
      resp_body = Jason.decode!(resp.resp_body)
      assert resp_body["error"] == "unauthenticated"
    end

    test "Auth user", %{conn: conn, token: token} do
      conn = conn |> put_req_header("authorization", "Bearer #{token}")
      resp = get(conn, order_path(conn, :index))
      resp_data = Jason.decode!(resp.resp_body)
      assert [] == resp_data["data"]
    end
  end
end
