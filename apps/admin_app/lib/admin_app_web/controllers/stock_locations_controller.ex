defmodule AdminAppWeb.StockLocationsController do
  use AdminAppWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
