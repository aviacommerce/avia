defmodule SnitchApiWeb.Plugs.LoadUser do
  use SnitchApiWeb.ConnCase, async: true

  import Snitch.Factory

  alias Snitch.Core.Tools.MultiTenancy.Repo
  alias SnitchApi.Accounts
  alias SnitchApiWeb.Plug.LoadUser

  setup %{conn: conn} do
    role = build(:role, name: "user")
    Repo.insert(role, on_conflict: :nothing)

    user = %{
      "data" => %{
        "attributes" => build(:user_with_no_role)
      }
    }

    conn =
      conn
      |> put_req_header("accept", "application/vnd.api+json")
      |> put_req_header("content-type", "application/vnd.api+json")

    {:ok, conn: conn, user: user}
  end

  describe "Loading User" do
    test "when user is not signin", %{conn: conn} do
      conn = LoadUser.call(conn, %{})
      assert nil == conn.assigns[:current_user]
    end

    test "when user in signed in", %{conn: conn, user: user} do
      user = JaSerializer.Params.to_attributes(user)
      {:ok, registered_user} = Accounts.create_user(user)

      # create the token
      {:ok, token, _claims} = SnitchApi.Guardian.encode_and_sign(registered_user)

      # add authorization header to request
      conn = conn |> put_req_header("authorization", "Bearer #{token}")
      conn = get(conn, order_path(conn, :index))
      conn = LoadUser.call(conn, %{})

      assert user["email"] == Map.get(conn.assigns[:current_user], :email)
    end
  end
end
