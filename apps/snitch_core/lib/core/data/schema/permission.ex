defmodule Snitch.Data.Schema.Permission do
  @moduledoc """
  Models User Permissions in the system.
  """
  use Snitch.Data.Schema

  @typedoc """
  Permissions limit access to a resource in the system.

  A `permission` is associated with a `role` and in turn can
  be used to provide access to a resource in the application
  based on the `role` of the `user`.
  """
  @type t :: %__MODULE__{}

  schema "snitch_permissions" do
    field(:code, :string)
    field(:description, :string)

    timestamps()
  end

  @create_fields ~w(code description)a
  @update_fields ~w(description)

  @doc """
  Returns a `Permission` changeset to `create` a permission.
  """
  @spec create_changeset(t, map) :: Ecto.Changeset.t()
  def create_changeset(%__MODULE__{} = permission, params) do
    permission
    |> cast(params, @create_fields)
    |> validate_required(:code)
    |> unique_constraint(:code)
  end

  @doc """
  Returns a `Permission` changeset to `update` a permission.
  """
  @spec update_changeset(t, map) :: Ecto.Changeset.t()
  def update_changeset(%__MODULE__{} = permission, params) do
    permission
    |> cast(params, @update_fields)
    |> unique_constraint(:code)
  end
end
