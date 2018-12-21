defmodule AdminAppWeb.PageController do
  use AdminAppWeb, :controller

  alias AdminAppWeb.Helpers

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
