defmodule SnitchApiWeb.TaxonomyControllerTest do
  use SnitchApiWeb.ConnCase, async: true

  setup %{conn: conn} do
    # create a user
    {:ok, user} =
      SnitchApi.Accounts.create_user(%{
        "first_name" => "foo",
        "last_name" => "boo",
        "password" => "fooboofoo",
        "password_confirmation" => "fooboofoo",
        "email" => "user@email.com"
      })

    # create the token
    {:ok, token, _claims} = SnitchApi.Guardian.encode_and_sign(user)

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
    assert json_response(conn, 200)["data"]
  end
end
