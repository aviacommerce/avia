defmodule Snitch.Tools.QueryHelper do
  @moduledoc """

  """
  alias Core.Tools.Helpers.TypeHelper, as: TH

  @spec get(module(), map() | non_neg_integer(), TH.repo_type()) ::
          TH.schema_type() | nil | no_return()
  def get(schema, id, repo) when is_integer(id) do
    repo.get(schema, id)
  end

  def get(schema, query_fields, repo) when is_map(query_fields) do
    repo.get_by(schema, query_fields)
  end

  @spec create(module(), map(), TH.repo_type()) :: TH.commit_response_type()
  def create(schema, query_fields, repo) when is_map(query_fields) do
    schema.__struct__
    |> schema.changeset(query_fields, :create)
    |> commit_if_valid(:create, repo)
  end

  @spec update(module(), map(), nil | struct(), TH.repo_type()) :: TH.commit_response_type()
  def update(schema, query_fields, instance \\ nil, repo)

  def update(schema, query_fields, nil, repo) when is_map(query_fields) do
    schema
    |> get(query_fields.id, repo)
    |> schema.changeset(query_fields, :update)
    |> commit_if_valid(:update, repo)
  end

  def update(schema, query_fields, instance, repo)
      when is_map(query_fields) and is_map(instance) do
    instance
    |> schema.changeset(query_fields, :update)
    |> commit_if_valid(:update, repo)
  end

  @spec delete(module(), non_neg_integer() | struct(), TH.repo_type()) ::
          TH.commit_response_type()
  def delete(schema, id, repo) when is_integer(id) do
    with {:ok, instance} <- repo.get(schema, id) do
      delete(schema, instance, repo)
    else
      _ -> {:error, :not_found}
    end
  end

  def delete(_schema, instance, repo) when is_map(instance) do
    repo.delete(instance)
  end

  @spec commit_if_valid(TH.changeset_type(), atom(), TH.repo_type()) :: TH.commit_response_type()
  defp commit_if_valid(changeset, action, repo) do
    if changeset.valid? do
      case action do
        :create -> repo.insert(changeset)
        :update -> repo.update(changeset)
      end
    else
      {:error, changeset.errors}
    end
  end
end
