defmodule StoreFrontWeb.PageController do
  use StoreFrontWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
