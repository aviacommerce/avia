defmodule Core.Snitch.Data.Model do
  @moduledoc false

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
