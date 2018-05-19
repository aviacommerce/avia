defmodule AdminAppWeb.StockLocationView do
  use AdminAppWeb, :view

  def render("index.json", %{stock_locations: stock_locations}) do
    %{data: render_many(stock_locations, AdminAppWeb.StockLocationView, "stock_location.json")}
  end

  def render("stock_location.json", %{stock_location: stock_location}) do
    %{
      id: stock_location.id,
      name: stock_location.name,
      active: stock_location.active
    }
  end
end
