defmodule AdminAppWeb.PageController do
  use AdminAppWeb, :controller

  alias AdminAppWeb.Helpers

  def index(conn, _params) do
    case conn.request_path do
      "/" ->
        redirect(conn, to: dashboard_path(conn, :index))

      _ ->
        render(conn, "index.html")
    end
  end
end
