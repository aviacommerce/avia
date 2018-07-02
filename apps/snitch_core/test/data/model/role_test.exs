defmodule Snitch.Data.Model.RoleTest do
  use ExUnit.Case
  use Snitch.DataCase
  import Snitch.Factory
  alias Snitch.Data.Model.Role
  alias Snitch.Data.Schema.Role, as: RoleSchema

  @params %{
    name: "admin",
    description: "can manage everything in system"
  }

  test "create successfully" do
    assert {:ok, _} = Role.create(@params)
  end

  test "creation fails for duplicate name" do
    role = insert(:role)
    params = %{name: role.name, description: "can manage"}
    assert {:error, changeset} = Role.create(params)
    assert %{name: ["has already been taken"]} = errors_on(changeset)
  end

  test "udpate role successfully" do
    role = insert(:role)
    params = %{description: "can manage entire system"}
    assert {:ok, new_role} = Role.update(params, role)
    assert new_role.id == role.id
    assert new_role.description != role.description
  end

  test "delete a role" do
    role = insert(:role)
    assert {:ok, _} = Role.delete(role)
    assert Repo.get(RoleSchema, role.id) == nil
  end

  test "deletion failed not found" do
    assert {:error, :not_found} = Role.delete(-1)
  end

  test "get role" do
    role = insert(:role)
    assert role_returned = Role.get(role.id)
    assert role_returned == role
    assert {:ok, _} = Role.delete(role)
    assert Role.get(role.id) == nil
  end

  test "get all roles" do
    role = insert(:role)
    assert Role.get_all() != []
  end
end
