defmodule Core.Snitch.Data.Schema do
  @moduledoc false

  defmacro __using__(_) do
    quote do
      use Ecto.Schema
      import Ecto.Changeset

      alias Core.Snitch.Data.Schema

      alias Schema.{
        # Inventory
        Inventory.StockItem,
        Inventory.StockLocation
      }
    end
  end
end
