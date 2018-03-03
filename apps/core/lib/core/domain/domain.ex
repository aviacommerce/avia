defmodule Core.Snitch.Domain do
  @moduledoc """
    Interface for handling Business related logics.
    Uses Models for DB related queries.
  """

  defmacro __using__(_) do
    quote do
      alias Core.Snitch.{Data.Model, Data.Schema, Domain, Repo}
      alias Ecto.Multi
    end
  end
end
