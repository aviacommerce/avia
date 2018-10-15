defmodule Snitch.Data.Schema do
  @moduledoc """
  Interface for DB tables with rules.
  """

  defmacro __using__(_) do
    quote do
      use Ecto.Schema
      import Ecto.Changeset
      import Snitch.Tools.Validations
      alias Snitch.Core.Tools.MultiTenancy.Repo
    end
  end
end
