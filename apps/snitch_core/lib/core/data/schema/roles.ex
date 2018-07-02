defmodule Snitch.Data.Schema.Role do
  @moduledoc """
  Models the User Roles.
  """

  use Snitch.Data.Schema
  alias Snitch.Data.Schema.{Permission, User}

  @type t :: %__MODULE__{}

  schema "snitch_roles" do
    field(:name, :string)
    field(:description, :string)

    # associations
    has_many(:users, User)
    many_to_many(:permissions, Permission, join_through: "role_permissions")

    timestamps()
  end

  @required_params ~w(name)a
  @optional_params ~w(description)a
  @params @required_params ++ @optional_params

  @doc """
  Returns a changeset to create a new `role`.
  """
  @spec create_changeset(t, map) :: Ecto.Changeset.t()
  def create_changeset(%__MODULE__{} = role, params) do
    common_changeset(role, params)
  end

  @doc """
  Returns a changeset to update a `role`.
  """
  @spec update_changeset(t, map) :: Ecto.Changeset.t()
  def update_changeset(%__MODULE__{} = role, params) do
    common_changeset(role, params)
  end

  defp common_changeset(role, params) do
    role
    |> cast(params, @params)
    |> validate_required(@required_params)
    |> unique_constraint(:name)
  end
end
