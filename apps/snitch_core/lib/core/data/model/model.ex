defmodule Snitch.Data.Model do
  @moduledoc """
  Interface for handling DB related changes
  """

  defmacro __using__(_) do
    quote do
      import Ecto.Query
      alias Snitch.Core.Tools.MultiTenancy.Repo
      alias Snitch.Tools
      alias Tools.Helper.Query, as: QH
    end
  end
end
