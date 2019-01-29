defmodule AdminAppWeb.Api.StockController do
  use AdminAppWeb, :controller

  alias Snitch.Domain.Inventory
  alias Snitch.Data.Model.StockItem
  alias Snitch.Data.Model.Product, as: ProductModel
  alias Snitch.Data.Schema.Product

  def get_stock(conn, params) do
    stock = StockItem.get_stock(params["product_id"], params["stock_location_id"])
    render(conn, "stocks.json", %{stocks: stock})
  end

  def update_stock(conn, params) do
    with {:ok, %Product{} = product} <- ProductModel.get(params["stock"]["product_id"]),
         {:ok, stock} <- Inventory.add_stock(product, params["stock"]) do
      render(conn, "stocks.json", %{stocks: [stock]})
    else
      {:error, _changeset} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: %{message: "Bad request"}})
    end
  end
end
