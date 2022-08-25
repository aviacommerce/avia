defmodule AdminAppWeb.PageController do
  use AdminAppWeb, :controller

  def index(conn, _params) do
    redirect(conn, to: live_path(conn, AdminAppWeb.Live.Dashboard))
  end
end
