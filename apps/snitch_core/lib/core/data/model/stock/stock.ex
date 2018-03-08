defmodule Snitch.Core.Data.Model.Stock do
  @moduledoc """
  Interface for handling DB related changes
  """

  defmacro __using__(_) do
    quote do
      alias Snitch.Data.Model.{
        StockItem,
        StockLocation
      }
    end
  end
end
