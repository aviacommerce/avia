defmodule Snitch.Core.Data.Schema.Stock do
  @moduledoc """
    Interface for DB tables with rules.
  """

  defmacro __using__(_) do
    quote do
      alias Snitch.Core.Data.Schema.Stock.{
        StockItem,
        StockLocation
      }
    end
  end
end
