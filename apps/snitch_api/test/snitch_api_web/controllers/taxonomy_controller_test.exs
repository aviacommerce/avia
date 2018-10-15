defmodule SnitchApiWeb.TaxonomyControllerTest do
  use SnitchApiWeb.ConnCase, async: true

  import Snitch.Factory

  alias Snitch.Core.Tools.MultiTenancy.Repo
  alias SnitchApi.Accounts

  setup %{conn: conn} do
    user = build(:user_with_no_role)
    role = build(:role, name: "user")

    Repo.insert(role, on_conflict: :nothing)

    {:ok, registered_user} = Accounts.create_user(user)

    # create the token
    {:ok, token, _claims} = SnitchApi.Guardian.encode_and_sign(registered_user)

    # add authorization header to request
    conn =
      conn
      |> put_req_header("accept", "application/vnd.api+json")
      |> put_req_header("content-type", "application/vnd.api+json")
      |> put_req_header("authorization", "Bearer #{token}")

    # pass the connection and the user to the test
    {:ok, conn: conn}
  end

  test "lists all taxonomies entries on index", %{conn: conn} do
    conn = get(conn, taxonomy_path(conn, :index))
    assert json_response(conn, 200)["taxonomies"]
  end
end
