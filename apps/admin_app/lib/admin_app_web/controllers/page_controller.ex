defmodule AdminAppWeb.PageController do
  use AdminAppWeb, :controller

  alias AdminAppWeb.Helpers

  def index(conn, _params) do
    redirect(conn, to: dashboard_path(conn, :index))
  end

  def react_app(conn, _params) do
    render(conn, "index.html")
  end
end
