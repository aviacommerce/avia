defmodule Snitch.Data.Model.User do
  @moduledoc """
  User API
  """
  use Snitch.Data.Model
  alias Snitch.Data.Schema.User, as: UserSchema

  @spec create(map) :: {:ok, UserSchema.t()} | {:error, Ecto.Changeset.t()}
  def create(query_fields) do
    QH.create(UserSchema, query_fields, Repo)
  end

  @spec update(map, UserSchema.t()) :: {:ok, UserSchema.t()} | {:error, Ecto.Changeset.t()}
  def update(query_fields, instance) do
    QH.update(UserSchema, query_fields, instance, Repo)
  end

  @spec delete(non_neg_integer | UserSchema.t()) ::
          {:ok, Ecto.Schema.t()} | {:error, Ecto.Changeset.t()}
  def delete(id_or_instance) do
    QH.delete(UserSchema, id_or_instance, Repo)
  end

  @spec get(map | non_neg_integer) :: UserSchema.t() | nil
  def get(query_fields_or_primary_key) do
    QH.get(UserSchema, query_fields_or_primary_key, Repo)
  end

  @spec get_all() :: [UserSchema.t()]
  def get_all(), do: Repo.all(UserSchema)
end
