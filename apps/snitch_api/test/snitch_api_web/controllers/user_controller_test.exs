defmodule SnitchApiWeb.UserControllerTest do
  use SnitchApiWeb.ConnCase, async: true

  alias SnitchApi.Accounts

  @create_attrs %{
    email: "mail@email.com",
    password: "letmehackyou",
    password_confirmation: "letmehackyou",
    first_name: "foo",
    last_name: "boo"
  }

  @invalid_attrs %{email: nil, password: nil}

  setup %{conn: conn} do
    conn =
      conn
      |> put_req_header("accept", "application/vnd.api+json")
      |> put_req_header("content-type", "application/vnd.api+json")

    {:ok, conn: conn}
  end

  describe "Register user" do
    test "renders user when data is valid", %{conn: conn} do
      conn = post(conn, user_path(conn, :create), user: @create_attrs)
      assert %{"id" => _id} = json_response(conn, 200)["data"]

      conn =
        post(
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

  describe "Authenticated routing" do
    setup %{conn: conn} do
      # create a user
      {:ok, user} =
        Accounts.create_user(%{
          "first_name" => "foo",
          "last_name" => "boo",
          "password" => "fooboofoo",
          "password_confirmation" => "fooboofoo",
          "email" => "user@email.com",
          "username" => "username"
        })

      # create the token
      {:ok, token, _claims} = SnitchApi.Guardian.encode_and_sign(user)

      # add authorization header to request
      conn = conn |> put_req_header("authorization", "Bearer #{token}")

      # pass the connection and the user to the test
      {:ok, conn: conn, user: user}
    end

    test "fetching logged in user", %{conn: conn, user: user} do
      conn = get(conn, user_path(conn, :current_user))

      assert %{
               "id" => Map.get(user, :id),
               "email" => "user@email.com",
               "first_name" => "foo",
               "last_name" => "boo"
             } == json_response(conn, 200)["data"]
    end

    test "logging out user", %{conn: conn} do
      conn = post(conn, user_path(conn, :logout))
      assert %{"status" => "logged out"} = json_response(conn, 204)
    end
  end
end
