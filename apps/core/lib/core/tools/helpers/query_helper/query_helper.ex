defmodule Core.Tools.Helpers.QueryHelper do
  @moduledoc """

  """
  def get(schema, id, repo) when is_integer(id) do
    repo.get(schema, id)
  end

  def get(schema, query_fields, repo) when is_map(query_fields) do
    repo.get_by(schema, query_fields)
  end

  def create(schema, query_fields, repo) when is_map(query_fields) do
    schema.__struct__
    |> schema.changeset(query_fields, :create)
    |> __commit_if_valid(:create, repo)
  end

  def update(schema, query_fields, instance \\ nil, repo)

  def update(schema, query_fields, nil, repo) when is_map(query_fields) do
    schema
    |> get(query_fields.id, repo)
    |> schema.changeset(query_fields, :update)
    |> __commit_if_valid(:update, repo)
  end

  def update(schema, query_fields, instance, repo)
      when is_map(query_fields) and is_map(instance) do
    instance
    |> schema.changeset(query_fields, :update)
    |> __commit_if_valid(:update, repo)
  end

  def delete(schema, id, repo) when is_integer(id) do
    # hard delete logic
  end

  def delete(schema, instance, repo) when is_map(instance) do
    # hard delete logic
  end

  def undo_delete(schema, id, repo) when is_integer(id) do
    update(schema, %{id: id, deleted: false}, nil, repo)
  end

  def undo_delete(schema, instance, repo) when is_map(instance) do
    update(schema, %{deleted: false}, instance, repo)
  end

  defp __commit_if_valid(changeset, operation, repo) do
    if changeset.valid? do
      {status, result} =
        case operation do
          :create -> repo.insert(changeset)
          :update -> repo.update(changeset)
        end

      {status, result}
    else
      {:error, changeset.errors}
    end
  end
end
