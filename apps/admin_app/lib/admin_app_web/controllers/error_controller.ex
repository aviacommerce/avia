defmodule AdminAppWeb.ErrorController do
  use AdminAppWeb, :controller

  def index(conn, _params) do
    conn
    |> put_status(404)
    |> put_layout(false)
    |> render("404.html")
  end
end
