defmodule SnitchApiWeb.AddressControllerTest do
  use SnitchApiWeb.ConnCase, async: true
  import Snitch.Factory

  setup :states
  # setup :countries

  @create_attrs %{
    first_name: "some data",
    last_name: "some data 2",
    address_line_1: "some data 2",
    address_line_2: "some data 2",
    city: "Shark",
    phone: "0120120",
    state_id: 1969,
    country_id: 105,
    zip_code: "12345"
  }

  @false_address %{
    first_name: "some data",
    last_name: "some data 2",
    city: "Shark",
    phone: "0120120",
    state_id: 1969,
    country_id: 105,
    zip_code: "12345"
  }

  setup %{conn: conn} do
    conn =
      conn
      |> put_req_header("accept", "application/vnd.api+json")
      |> put_req_header("content-type", "application/vnd.api+json")

    {:ok, conn: conn}
  end

  describe "Add Address" do
    test "List address", %{conn: conn} do
      conn = get(conn, address_path(conn, :index))
      assert json_response(conn, 200)["data"]
    end

    test "Add address with vaild data", %{conn: conn, states: states} do
      state = List.first(states)
      params = Map.merge(@create_attrs, %{state_id: state.id, country_id: state.country.id})

      conn =
        post(conn, address_path(conn, :create), %{data: %{type: "address", attributes: params}})

      assert json_response(conn, 200)["data"]
    end

    test "Add address with out vaild data", %{conn: conn, states: states} do
      state = List.first(states)
      params = Map.merge(@false_address, %{state_id: state.id, country_id: state.country.id})

      conn =
        post(conn, address_path(conn, :create), %{data: %{type: "address", attributes: params}})

      assert json_response(conn, 422) == %{"errors" => %{"address_line_1" => ["can't be blank"]}}
    end
  end
end
