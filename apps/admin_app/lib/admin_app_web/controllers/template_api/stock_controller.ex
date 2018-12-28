defmodule AdminAppWeb.TemplateApi.StockController do
  use AdminAppWeb, :controller

  alias Snitch.Domain.Inventory

  def update_stock(conn, params) do
    Inventory.add_stock(params["product_id"],
    params["stock_location_id"],
    params["current_stock"],
    0)
    conn
    |> put_status(:ok)
  end
end
