defmodule SnitchApiWeb.OrderControllerTest do
  use SnitchApiWeb.ConnCase, async: true
  import Snitch.Factory
  alias Snitch.Data.Model.Order, as: OrderModel
  alias Snitch.Core.Tools.MultiTenancy.Repo
  alias SnitchApi.Accounts
  alias SnitchApi.{Accounts, Guardian}

  setup_all do
    Application.put_env(:snitch_core, :defaults, currency: :USD)
  end

  setup %{conn: conn} do
    insert(:role, name: "user")
    user = build(:user_with_no_role)

    conn =
      conn
      |> put_req_header("accept", "application/vnd.api+json")
      |> put_req_header("content-type", "application/vnd.api+json")

    {:ok, conn: conn, user: user}
  end

  describe "un_authorized users accessing api" do
    test "Empty order creation for guest user", %{conn: conn} do
      conn = post(conn, order_path(conn, :guest_order))
      assert json_response(conn, 200)["data"]
    end

    test "error on accessing orders api", %{conn: conn} do
      resp = get(conn, order_path(conn, :index))
      assert resp.status == 403
      resp_body = Jason.decode!(resp.resp_body)
      assert resp_body["error"] == "unauthenticated"
    end

    test "Fetching Guest Order matcing order number", %{conn: conn} do
      conn = post(conn, order_path(conn, :guest_order))
      order = json_response(conn, 200)["data"]

      conn =
        get(conn, order_path(conn, :fetch_guest_order, get_in(order, ["attributes", "number"])))

      assert Map.get(order, "id") == json_response(conn, 200)["data"]["id"]
    end

    test "Fetching Guest Order non matching order number", %{conn: conn} do
      conn = get(conn, order_path(conn, :fetch_guest_order, "i don't match"))
      assert nil == json_response(conn, 200)["data"]
    end
  end

  describe "Authorized User Accessing Order API" do
    setup %{conn: conn, user: user} do
      {:ok, registered_user} = Accounts.create_user(user)
      {:ok, token, _claims} = Guardian.encode_and_sign(registered_user)
      conn = put_req_header(conn, "authorization", "Bearer #{token}")
      {:ok, conn: conn, reg_user: registered_user}
    end

    test "creating new order when current order is not existed", %{conn: conn} do
      conn = post(conn, order_path(conn, :current))
      assert json_response(conn, 200)["data"]
    end

    test "fetching existing order of the logged in user", %{conn: conn, reg_user: %{id: user_id}} do
      order = insert(:order, user_id: user_id)
      conn = post(conn, order_path(conn, :current))
      assert Integer.to_string(order.id) == json_response(conn, 200)["data"]["id"]
    end

    test "Listing out the orders", %{conn: conn} do
      conn = get(conn, order_path(conn, :index))
      assert json_response(conn, 200)["data"]

      resp_data = Jason.decode!(conn.resp_body)
      assert [] == resp_data["data"]
    end

    test "Adding selected address to an order", %{conn: conn, reg_user: reg_user} do
      order =
        :order
        |> insert(user_id: reg_user.id)
        |> Repo.preload(:line_items)

      {:ok, order} =
        OrderModel.update(
          %{
            line_items: [],
            item_total: Money.zero(:USD),
            total: Money.zero(:USD)
          },
          order
        )

      address_params = [
        :address_line_1,
        :address_line_2,
        :alternate_phone,
        :city,
        :country_id,
        :first_name,
        :last_name,
        :phone,
        :state_id,
        :zip_code
      ]

      address =
        :address
        |> insert()
        |> Map.take(address_params)

      params = %{
        "data" => %{
          attributes: %{
            shipping_address: address,
            billing_address: address
          },
          type: "order",
          id: order.id
        }
      }

      conn = post(conn, order_path(conn, :select_address, order.id, params))
      assert json_response(conn, 200)["data"]
    end
  end
end
