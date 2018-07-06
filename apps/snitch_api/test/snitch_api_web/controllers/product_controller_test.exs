defmodule SnitchApiWeb.ProductControllerTest do
  use SnitchApiWeb.ConnCase, async: true

  alias Snitch.Data.Schema.Product
  alias Snitch.Repo

  setup %{conn: conn} do
    conn =
      conn
      |> put_req_header("accept", "application/vnd.api+json")
      |> put_req_header("content-type", "application/vnd.api+json")

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
end
