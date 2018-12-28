defmodule Snitch.Domain.Inventory do
  @moduledoc """
  Interface for handling inventory related business logic
  """

  alias Snitch.Data.Model.StockItem, as: StockModel
  alias Snitch.Data.Schema.StockItem, as: StockSchema

  use Snitch.Domain

  def add_stock(product_id, stock_location_id, stock_level, stock_low_level) do
    params = %{count_on_hand: stock_level}

    with {:ok, stock} <- check_stock(product_id, stock_location_id),
         {:ok, updated_stock} <- StockModel.update(params, stock) do
      {:ok, updated_stock}
    end
  end

  defp check_stock(product_id, location_id) do
    query_fields = %{product_id: product_id, stock_location_id: location_id}

    case StockModel.get(query_fields) do
      %StockSchema{} = stock_item -> {:ok, stock_item}
      nil -> StockModel.create(product_id, location_id, 0, false)
    end
  end
end
