defmodule Core.Snitch.Data.Schema do
  @moduledoc false

  defmacro __using__(_) do
    quote do
      use Ecto.Schema
      import Ecto.Changeset

      alias Core.Snitch.Data.Schema

      alias Schema.{
        # Stock
        Stock.StockItem,
        Stock.StockLocation
      }
    end
  end
end
