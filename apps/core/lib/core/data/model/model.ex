defmodule Snitch.Core.Data.Model do
  @moduledoc """
    Interface for handling DB related changes
  """

  defmacro __using__(_) do
    quote do
      use Snitch.Core.Data.Model.{
        Stock
      }

      import Ecto.Query

      alias Core.Repo
      alias Snitch.Core.Tools
      alias Tools.QueryHelper, as: QH

      alias Snitch.Core.Data.{Schema, Model}
    end
  end
end
