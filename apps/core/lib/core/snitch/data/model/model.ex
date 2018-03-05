defmodule Core.Snitch.Data.Model do
  @moduledoc """
    Interface for handling DB related changes
  """

  alias Core.Repo

  defmacro __using__(_) do
    quote do
      import Ecto.Query

      alias Core.{Repo, Tools.Helpers}
      alias Helpers.QueryHelper, as: QH
      alias Helpers.TypeHelper, as: TH

      alias Core.Snitch.Data.{Schema, Model}

      use Core.Snitch.Data.Model.{
        Stock
      }
    end
  end
end
