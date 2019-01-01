defmodule AdminAppWeb.Api.StockController do
  use AdminAppWeb, :controller

  alias Snitch.Data.Model.StockItem

  def get_stock(conn, params) do
    stock = StockItem.get_stock(params["product_id"], params["stock_location_id"])
    render(conn, "stocks.json", %{stocks: stock})
  end
end
