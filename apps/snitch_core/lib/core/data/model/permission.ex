defmodule Snitch.Data.Model.Permission do
  @moduledoc """
  Permission API.
  """

  use Snitch.Data.Model
  alias Snitch.Data.Schema.Permission

  @doc """
  Creates a `permission` with supplied `params`.

  > Note
  > "code" should be unique amongst permissions.
  """
  @spec create(map) :: {:ok, Permission.t()} | {:error, Ecto.Changeset.t()}
  def create(params) do
    QH.create(Permission, params, Repo)
  end

  @doc """
  Updates a permission with the supplied params.

  To update either the `id` field should be supplied in the
  `params` map or, the `struct` of the `permission` to be updated
  should be passed as second argument.
  """
  @spec update(map) :: {:ok, Permission.t() | nil} | {:error, Ecto.Changeset.t()}
  def update(params, instance \\ nil) do
    QH.update(Permission, params, instance, Repo)
  end

  @doc """
  Deletes a `permission`  in the system.

  Takes as input `id` of the Permission  to be deleted.
  """
  @spec delete(integer) ::
          {:ok, Permission.t()}
          | {:error, Ecto.ChangeSet.t()}
          | {:error, :not_found}
  def delete(id) do
    case QH.get(Permission, id, Repo) do
      {:error, msg} ->
        {:error, msg}

      {:ok, permission} ->
        permission
        |> Permission.changeset()
        |> Repo.delete()
    end
  end

  @doc """
  Returns a permission .

  Takes as input `id` of the Permission  to be retrieved.
  """
  @spec get(integer) :: {:ok, Permission.t()} | {:error, atom}
  def get(id) do
    QH.get(Permission, id, Repo)
  end

  @doc """
  Returns all the permissions in the system.
  """
  @spec get_all() :: [Permission.t()]
  def get_all do
    Repo.all(Permission)
  end

  @doc """
  Returns a list of permission in the format {Permission .name, Permission .id}
  """
  @spec formatted_list() :: [{String.t(), non_neg_integer}]
  def formatted_list do
    Repo.all(from(c in Permission, select: {c.code, c.id}))
  end
end
