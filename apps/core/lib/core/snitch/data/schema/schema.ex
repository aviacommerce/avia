defmodule Core.Snitch.Data.Schema do
  @moduledoc """
    Interface for DB tables with rules.
  """

  defmacro __using__(_) do
    quote do
      use Ecto.Schema
      use Core.Snitch.Data.Schema.{Stock}

      alias Core.Snitch.Data.Schema.{
        LineItem,
        Order
      }

      import Ecto.Changeset
    end
  end
end
