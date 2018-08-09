defmodule Snitch.Data.Schema.RolePermission do
  @moduledoc """
  Role Permissions relate `roles` to `permissions`.

  A `role` can have multiple `permissions` in the system,
  similarly, a `permission` can be associated with multiple
  `roles`. The `role_permission` acts as a middle table to associate
  `roles` with `permissions`.
  """
  use Snitch.Data.Schema
  alias Snitch.Data.Schema.{Permission, Role}

  @type t :: %__MODULE__{}

  schema "role_permissions" do
    belongs_to(:role, Role)
    belongs_to(:permission, Permission)

    timestamps()
  end

  @spec create_changeset(t, map) :: Ecto.Changeset.t()
  def create_changeset(%__MODULE__{} = role_permisssion, params) do
    role_permisssion
    |> cast(params, [:role_id, :permission_id])
    |> validate_required([:role_id, :permission_id])
    |> foreign_key_constraint(:role)
    |> foreign_key_constraint(:permission)
  end
end
