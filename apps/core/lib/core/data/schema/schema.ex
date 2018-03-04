defmodule Snitch.Core.Data.Schema do
  @moduledoc """
    Interface for DB tables with rules.
  """

  defmacro __using__(_) do
    quote do
      use Ecto.Schema
      use Snitch.Core.Data.Schema.{Stock}
      import Ecto.Changeset

      alias Snitch.Core.Data.Schema.{
        Address,
        Country,
        LineItem,
        Order,
        State,
        User,
        Variant
      }
    end
  end
end
