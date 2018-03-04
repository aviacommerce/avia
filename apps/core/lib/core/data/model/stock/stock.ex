defmodule Snitch.Core.Data.Model.Stock do
  @moduledoc """
    Interface for handling DB related changes
  """

  defmacro __using__(_) do
    quote do
      alias Snitch.Core.Data.Model.Stock.{
        StockItem,
        StockLocation
      }
    end
  end
end
