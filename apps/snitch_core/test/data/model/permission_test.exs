defmodule Snitch.Data.Model.PermissionTest do
  use ExUnit.Case
  use Snitch.DataCase
  import Snitch.Factory
  alias Snitch.Data.Model.Permission
  alias Snitch.Data.Schema.Permission, as: PermissionSchema

  @params %{
    code: "manage_order",
    description: "Permission grants all access to order"
  }

  test "create successfully" do
    assert {:ok, _} = Permission.create(@params)
  end

  test "creation fails for duplicate code" do
    permission = insert(:permission)
    params = %{code: permission.code, description: "can manage products"}
    assert {:error, changeset} = Permission.create(params)
    assert %{code: ["has already been taken"]} = errors_on(changeset)
  end

  test "udpate permission successfully" do
    permission = insert(:permission)
    params = %{description: "can manage entire system"}
    assert {:ok, new_permission} = Permission.update(params, permission)
    assert new_permission.id == permission.id
    assert new_permission.description != permission.description
  end

  test "delete a permission" do
    permission = insert(:permission)
    assert {:ok, _} = Permission.delete(permission.id)
    assert Repo.get(PermissionSchema, permission.id) == nil
  end

  test "get permission" do
    permission = insert(:permission)
    assert {:ok, permission_returned} = Permission.get(permission.id)
    assert permission_returned == permission
    assert {:ok, _} = Permission.delete(permission.id)
    assert Permission.get(permission.id) == {:error, :permission_not_found}
  end

  test "get all permissions" do
    _permission = insert(:permission)
    assert Permission.get_all() != []
  end
end
