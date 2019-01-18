defmodule Snitch.Data.Model.Role do
  @moduledoc """
  Role API.
  """

  use Snitch.Data.Model
  alias Ecto.Multi
  alias Snitch.Data.Schema.Role
  alias Snitch.Data.Schema.RolePermission

  @doc """
  Creates a `role` with supplied `params`.

  A `role` is created in the system along with
  certain `permissions`, refer `Snitch.Data.Schema.Permission`.
  The `create` function expects a list of `permission` `ids`
  in `params` in order to perform the association, while creating
  the role with the supplied `name` and `description`.

  `params` is a `map` which can have following fields:
  `name`: name of the role
  `description`: description of the role
  `permissions`: [permissions_ids]

  > #### Note
  > "name" should be unique amongst roles.
  > If permissions list is not present role would be created
  > without any permissions.
  """
  @spec create(map) :: {:ok, Role.t()} | {:error, Ecto.Changeset.t()}
  def create(%{permissions: permissions} = params) when permissions != [] do
    Multi.new()
    |> Multi.run(:role, fn _ ->
      QH.create(Role, params, Repo)
    end)
    |> permissions_multi(params)
    |> persist()
  end

  def create(params) do
    QH.create(Role, params, Repo)
  end

  @doc """
  Updates a role with the supplied params.

  To update, either the `id` field should be supplied in the
  `params` map or, the `instance` of the `role` to be updated
  should be passed as second argument.

  If `permissions` field containing a list of `permission_ids`
  is, supplied in `params` then the association with `permissions`
  is updated and earlier assciations are removed.
  """
  @spec update(map) :: {:ok, Role.t() | nil} | {:error, Ecto.Changeset.t()}
  def update(params, instance \\ nil)

  def update(%{permissions: _} = params, instance) do
    Multi.new()
    |> remove_associations(instance)
    |> Multi.run(:role, fn _ ->
      QH.update(Role, params, instance, Repo)
    end)
    |> permissions_multi(params)
    |> persist()
  end

  def update(params, instance) do
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
  @spec get(integer) :: {:ok, Role.t()} | {:error, atom}
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
  Returns the role for the given roll_name.
  """
  @spec get_role_by_name(string) :: Role.t()
  def get_role_by_name(name) do
    Repo.get_by!(Role, name: name)
  end

  @doc """
  Returns a list of roles in the format {role.name, role.id}
  """
  @spec formatted_list() :: [{String.t(), non_neg_integer}]
  def formatted_list do
    Repo.all(from(c in Role, select: {c.name, c.id}))
  end

  #################### Private Functions ##############

  # to associcate role with permissions
  defp permissions_multi(multi, params) do
    Multi.run(multi, :permission, fn %{role: role} ->
      role_permissions = associate_role_permissions(role, params[:permissions])
      {count, _} = Repo.insert_all(RolePermission, role_permissions)
      {:ok, count}
    end)
  end

  defp associate_role_permissions(role, permissions) do
    Enum.map(permissions, fn permission ->
      [
        permission_id: permission,
        role_id: role.id,
        inserted_at: DateTime.utc_now(),
        updated_at: DateTime.utc_now()
      ]
    end)
  end

  # Run the accumulated multi struct
  defp persist(multi) do
    case Repo.transaction(multi) do
      {:ok, %{role: role}} ->
        {:ok, role}

      {:error, _, _, _} = error ->
        error
    end
  end

  # removes role associations from permisssions
  defp remove_associations(multi, instance) do
    Multi.run(multi, :remove_permissions, fn _ ->
      {count, _} =
        Repo.delete_all(from(role_p in RolePermission, where: role_p.role_id == ^instance.id))

      {:ok, count}
    end)
  end
end
