defmodule SnitchApiWeb.UserControllerTest do
  use SnitchApiWeb.ConnCase, async: true

  import Snitch.Factory

  alias SnitchApi.Accounts
  alias Snitch.Core.Tools.MultiTenancy.Repo

  @invalid_attrs %{email: nil, password: nil}

  setup %{conn: conn} do
    user = build(:user_with_no_role)
    role = build(:role, name: "user")

    Repo.insert(role, on_conflict: :nothing)

    user = %{
      "data" => %{
        "attributes" => user
      }
    }

    conn =
      conn
      |> put_req_header("accept", "application/vnd.api+json")
      |> put_req_header("content-type", "application/vnd.api+json")

    {:ok, conn: conn, user: user}
  end

  describe "User Registration" do
    test "creation and sign in with valid data", %{conn: conn, user: user} do
      conn = post(conn, user_path(conn, :create), user)
      assert %{"id" => _id} = json_response(conn, 200)["data"]

      conn =
        post(
          conn,
          user_path(conn, :login, user)
        )

      response = json_response(conn, 200)
      assert response["data"]["attributes"]["token"]
    end

    test "render errors when data is invalid", %{conn: conn} do
      conn = post(conn, user_path(conn, :create), user: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end

    test "login with empty parameters", %{conn: conn} do
      conn = post(conn, user_path(conn, :login))
      assert json_response(conn, 404)["errors"] == %{"detail" => "no login credentials"}
    end

    test "missing parameter in user registration", %{conn: conn} do
      user = %{
        "data" => %{
          "attributes" => build(:user_with_no_role) |> Map.delete("email")
        }
      }

      conn = post(conn, user_path(conn, :create), user)
      assert json_response(conn, 422)["errors"] == %{"email" => ["can't be blank"]}
    end
  end

  describe "Authenticated routing" do
    setup %{conn: conn, user: user} do
      user = JaSerializer.Params.to_attributes(user)
      {:ok, registered_user} = Accounts.create_user(user)

      # create the token
      {:ok, token, _claims} = SnitchApi.Guardian.encode_and_sign(registered_user)

      # add authorization header to request
      conn = conn |> put_req_header("authorization", "Bearer #{token}")
      conn = Plug.Conn.assign(conn, :current_user, registered_user)

      # pass the connection and the user to the test
      {:ok, conn: conn, user: registered_user}
    end

    test "fetching logged in user", %{conn: conn, user: user} do
      conn = get(conn, user_path(conn, :current_user))

      assert Map.get(user, :id) == json_response(conn, 200)["data"]["id"]
    end

    test "logging out user", %{conn: conn} do
      conn = post(conn, user_path(conn, :logout))
      assert %{"status" => "logged out"} = json_response(conn, 204)
    end

    test "authenticated user details", %{conn: conn} do
      conn = get(conn, user_path(conn, :authenticated))
      assert json_response(conn, 200)["data"]
    end
  end
end
