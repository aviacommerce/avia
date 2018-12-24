defmodule AdminAppWeb.PageController do
  use AdminAppWeb, :controller

  def index(conn, _params) do
    redirect(conn, to: dashboard_path(conn, :index))
  end
end
