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

      alias Core.Snitch.Data.{
        Schema,
        Model
      }
    end
  end
end
