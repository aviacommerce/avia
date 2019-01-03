defmodule AdminAppWeb.Api.StockView do
  use AdminAppWeb, :view

  def render("stocks.json", data) do
    %{
      data: render_many(data.stocks, __MODULE__, "stock.json", as: :stock)
    }
  end

  def render("stock.json", %{stock: stock}) do
    Map.take(stock, [:count_on_hand, :inventory_warning_level])
  end
end
