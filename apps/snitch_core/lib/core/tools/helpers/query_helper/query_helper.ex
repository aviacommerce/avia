defmodule Snitch.Tools.QueryHelper do
  @moduledoc """

  """

  @spec get(module, map | non_neg_integer, Ecto.Repo.t()) :: Ecto.Schema.t() | nil | no_return
  def get(schema, id, repo) when is_integer(id) do
    repo.get(schema, id)
  end

  def get(schema, query_fields, repo) when is_map(query_fields) do
    repo.get_by(schema, query_fields)
  end

  @spec create(module, map, Ecto.Repo.t()) ::
          {:ok, Ecto.Schema.t()} | {:error, Ecto.Changeset.t()}
  def create(schema, query_fields, repo) when is_map(query_fields) do
    schema.__struct__
    |> schema.changeset(query_fields, :create)
    |> commit_if_valid(:create, repo)
  end

  @spec update(module, map, nil | struct(), Ecto.Repo.t()) ::
          {:ok, Ecto.Schema.t()} | {:error, Ecto.Changeset.t()}
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

  @spec delete(module, non_neg_integer | struct(), Ecto.Repo.t()) ::
          {:ok, Ecto.Schema.t()} | {:error, Ecto.Changeset.t()} | {:error, :not_found}
  def delete(schema, id, repo) when is_integer(id) do
    case repo.get(schema, id) do
      nil -> {:error, :not_found}
      instance -> delete(schema, instance, repo)
    end
  end

  def delete(_schema, instance, repo) when is_map(instance) do
    repo.delete(instance)
  end

  @spec commit_if_valid(Ecto.Changeset.t(), atom(), Ecto.Repo.t()) ::
          {:ok, Ecto.Schema.t()} | {:error, Ecto.Changeset.t()}
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
