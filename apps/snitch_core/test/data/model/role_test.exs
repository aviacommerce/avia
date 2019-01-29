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

  describe "create" do
    setup :permissions

    @tag permission_count: 2
    test "successfully", context do
      %{permissions: permissions} = context
      id_list = permission_ids(permissions)
      params = Map.put(@params, :permissions, id_list)
      assert {:ok, _} = Role.create(params)
    end

    test "creation fails for duplicate name" do
      role = insert(:role)
      params = %{name: role.name, description: "can manage"}
      assert {:error, changeset} = Role.create(params)
      assert %{name: ["has already been taken"]} = errors_on(changeset)
    end
  end

  describe "udpate" do
    setup :permissions

    @tag permission_count: 2
    test "successfully along with permissions", context do
      role = insert(:role)
      role_with_permission = Repo.preload(role, :permissions)
      assert role_with_permission.permissions == []
      %{permissions: permissions} = context
      id_list = permission_ids(permissions)
      params = %{description: "can manage entire system", permissions: id_list}
      assert {:ok, new_role} = Role.update(params, role)
      assert new_role.id == role.id
      assert new_role.description != role.description
      assert role = Repo.preload(new_role, :permissions)
      refute role.permissions == []
    end
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
    assert {:ok, role_returned} = Role.get(role.id)
    assert role_returned.id == role.id
    assert {:ok, _} = Role.delete(role)
    assert Role.get(role.id) == {:error, :role_not_found}
  end

  test "get all roles" do
    insert(:role)
    assert Role.get_all() != []
  end

  defp permission_ids(permissions) do
    Enum.map(permissions, fn %{id: id} -> id end)
  end
end
