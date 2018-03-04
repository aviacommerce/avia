defmodule Snitch.Core.Data.Model do
  @moduledoc """
    Interface for handling DB related changes
  """

  defmacro __using__(_) do
    quote do
      import Ecto.Query

      alias Core.Repo
      alias Snitch.Core.Tools.Helpers
      alias Helpers.QueryHelper, as: QH

      alias Snitch.Core.Data.{Schema, Model}

      use Snitch.Core.Data.Model.{
        Stock
      }
    end
  end
end
