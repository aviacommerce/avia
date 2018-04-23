defmodule AdminAppWeb.PageControllerTest do
  use AdminAppWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Welcome to Snitch!"
  end
end
