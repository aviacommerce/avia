defmodule Core.Tools.Helpers.TypeHelper do
  @moduledoc """
    Define custom Spec Types here
  """
  @type repo_type :: Ecto.Repo.t()
  @type query_type :: Ecto.Query.t()
  @type schema_type :: Ecto.Schema.t()
  @type changeset_type :: Ecto.Changeset.t()
  @type commit_response_type :: {:ok, schema_type} | {:error, changeset_type}
end
