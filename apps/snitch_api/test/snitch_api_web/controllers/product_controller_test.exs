defmodule SnitchApiWeb.ProductControllerTest do
  use SnitchApiWeb.ConnCase, async: true

  alias Snitch.Data.Schema.Product
  alias Snitch.Repo

  setup %{conn: conn} do
    # create a user
    {:ok, user} =
      SnitchApi.Accounts.create_user(%{
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
    conn =
      conn
      |> put_req_header("accept", "application/vnd.api+json")
      |> put_req_header("content-type", "application/vnd.api+json")
      |> put_req_header("authorization", "Bearer #{token}")

    # pass the connection and the user to the test
    {:ok, conn: conn}
  end

  test "lists all products entries on index", %{conn: conn} do
    conn = get(conn, product_path(conn, :index))
    assert json_response(conn, 200)["data"]
  end

  test "shows chosen resource product", %{conn: conn} do
    [product | _] = Repo.all(Product)
    conn = get(conn, product_path(conn, :show, product.slug))

    assert json_response(conn, 200)["data"] |> Map.take(["id", "type"]) == %{
             "id" => "#{product.id}",
             "type" => "product"
           }
  end

  test "Products in Descending Order", %{conn: conn} do
    string = "ZZZZZ-I-Love-Night-Coding"

    Repo.insert(%Product{name: string, slug: string}, on_conflict: :nothing)

    params = %{"sort" => "Z-A"}

    conn = get(conn, product_path(conn, :index, params))

    response =
      json_response(conn, 200)["data"]
      |> List.first()
      |> JaSerializer.Params.to_attributes()
      |> Map.take(["name"])

    assert %{"name" => ^string} = response
  end

  test "Products in Ascending Order", %{conn: conn} do
    string = "AAAAA-I-Love-Night-Coding"

    Repo.insert(%Product{name: string, slug: string}, on_conflict: :nothing)

    params = %{"sort" => "A-Z"}

    conn = get(conn, product_path(conn, :index, params))

    response =
      json_response(conn, 200)["data"]
      |> List.first()
      |> JaSerializer.Params.to_attributes()
      |> Map.take(["name"])

    assert %{"name" => ^string} = response
  end

  test "Products, search contains name and pagination", %{conn: conn} do
    string = "XXXXX-I-Love-Night-Coding"
    string2 = "XXXXX-I-Love-Day-Coding"
    string3 = "XXXXX-I-Love-Coding-In-Vim"

    Repo.insert(%Product{name: string, slug: string}, on_conflict: :nothing)
    Repo.insert(%Product{name: string2, slug: string2}, on_conflict: :nothing)
    Repo.insert(%Product{name: string3, slug: string3}, on_conflict: :nothing)

    params = %{
      "filter" => %{"name" => "XXXXX"},
      "page" => %{"limit" => 3, "offset" => "1"}
    }

    conn = get(conn, product_path(conn, :index, params))

    response =
      json_response(conn, 200)["data"]
      |> Enum.count()

    assert response == 3
  end

  test "Products, sort by newly inserted", %{conn: conn} do
    string = "WOW-I-Love-Night-Coding"

    Repo.insert(%Product{name: string, slug: string}, on_conflict: :nothing)

    params = %{
      "sort" => "date"
    }

    conn = get(conn, product_path(conn, :index, params))

    response =
      json_response(conn, 200)["data"]
      |> List.first()
      |> JaSerializer.Params.to_attributes()
      |> Map.take(["name"])

    assert %{"name" => ^string} = response
  end
end
