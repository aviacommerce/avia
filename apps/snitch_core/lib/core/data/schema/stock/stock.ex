defmodule Snitch.Data.Schema.Stock do
  @moduledoc """
  Interface for DB tables with rules.
  """

  defmacro __using__(_) do
    quote do
      alias Snitch.Data.Schema.{
        StockItem,
        StockLocation,
        StockMovement,
        StockTransfer,
        ShipmentUnit
      }
    end
  end
end
