defmodule Snitch.Data.Model.Role do
  @moduledoc """
  Role API.
  """

  use Snitch.Data.Model
  alias Snitch.Data.Schema.Role

  @doc """
  Creates a `role` with supplied `params`.

  > ## Note
  > "name" should be unique amongst roles.
  """
  @spec create(map) :: {:ok, Role.t()} | {:error, Ecto.Changeset.t()}
  def create(params) do
    QH.create(Role, params, Repo)
  end

  @doc """
  Updates a role with the supplied params.

  To update either the `id` field in should be supplied in the
  `params` map or, the `instance` of the `role` to be updated
  should be passed as second argument.
  """
  @spec update(map) :: {:ok, Role.t() | nil} | {:error, Ecto.Changeset.t()}
  def update(params, instance \\ nil) do
    QH.update(Role, params, instance, Repo)
  end

  @doc """
  Deletes a role.

  Takes as input `id` or `instance` of the role to be deleted.
  """
  @spec delete(integer | Role.t()) ::
          {:ok, Role.t()}
          | {:error, Ecto.ChangeSet.t()}
          | {:error, :not_found}
  def delete(param) do
    QH.delete(Role, param, Repo)
  end

  @doc """
  Returns a role.

  Takes as input `id` of the role to be retrieved.
  """
  @spec get(integer) :: Role.t() | nil
  def get(id) do
    QH.get(Role, id, Repo)
  end

  @doc """
  Returns all the roles in the system.
  """
  @spec get_all() :: [Role.t()]
  def get_all do
    Repo.all(Role)
  end

  @doc """
  Returns a list of roles in the format {role.name, role.id}
  """
  @spec formatted_list() :: [{String.t(), non_neg_integer}]
  def formatted_list do
    Repo.all(from(c in Role, select: {c.name, c.id}))
  end
end
