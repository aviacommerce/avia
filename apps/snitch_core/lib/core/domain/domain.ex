defmodule Snitch.Domain do
  @moduledoc """
  Interface for handling Business related logics.
  Uses Models for DB related queries.
  """

  defmacro __using__(_) do
    quote do
      alias Ecto.Multi
      alias Snitch.Data.{Model, Schema}
      alias Snitch.Domain
      alias Snitch.Core.Tools.MultiTenancy.Repo
    end
  end
end
