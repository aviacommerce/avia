defmodule AdminAppWeb.PageController do
  use AdminAppWeb, :controller

  alias AdminAppWeb.Helpers

  def index(conn, _params) do
    conn
    |> redirect(to: dashboard_path(conn, :index))
  end
end
