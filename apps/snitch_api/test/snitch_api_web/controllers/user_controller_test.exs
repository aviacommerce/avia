defmodule SnitchApiWeb.UserControllerTest do
  use SnitchApiWeb.ConnCase

  alias SnitchApi.Accounts
  alias SnitchApi.Accounts.User

  @create_attrs %{
    email: "mail@email.com",
    password: "letmehackyou",
    password_confirm: "letmehackyou",
    first_name: "foo",
    last_name: "boo"
  }
  @invalid_attrs %{email: nil, password: nil}

  def fixture(:user) do
    {:ok, user} = Accounts.create_user(@create_attrs)
    user
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all users", %{conn: conn} do
      conn = get(conn, user_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "Register user" do
    test "renders user when data is valid", %{conn: conn} do
      conn = post(conn, user_path(conn, :create), user: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, user_path(conn, :show, id))

      assert json_response(conn, 200)["data"]["id"] == id

      conn =
        get(
          conn,
          user_path(conn, :login, %{"email" => "mail@email.com", "password" => "letmehackyou"})
        )

      assert json_response(conn, 200)["token"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, user_path(conn, :create), user: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  defp create_user(_) do
    user = fixture(:user)
    {:ok, user: user}
  end
end
