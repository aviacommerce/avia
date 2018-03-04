defmodule Snitch.Core.Domain do
  @moduledoc """
    Interface for handling Business related logics.
    Uses Models for DB related queries.
  """

  defmacro __using__(_) do
    quote do
      alias Core.Repo
      alias Snitch.Core.{Data.Model, Data.Schema, Domain}
      alias Ecto.Multi
    end
  end
end
