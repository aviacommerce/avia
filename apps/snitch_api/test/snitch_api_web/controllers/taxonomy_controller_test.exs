defmodule SnitchApiWeb.TaxonomyControllerTest do
  use SnitchApiWeb.ConnCase, async: true

  setup %{conn: conn} do
    conn =
      conn
      |> put_req_header("accept", "application/vnd.api+json")
      |> put_req_header("content-type", "application/vnd.api+json")

    {:ok, conn: conn}
  end

  test "lists all taxonomies entries on index", %{conn: conn} do
    conn = get(conn, taxonomy_path(conn, :index))
    assert json_response(conn, 200)["data"]
  end
end
