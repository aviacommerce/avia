defmodule Snitch.Data.Schema.PermissionTest do
  use ExUnit.Case
  use Snitch.DataCase
  alias Snitch.Data.Schema.Permission

  @params %{
    code: "manage_post",
    description: "permission grants all access to order"
  }

  test "creation fails if code not provided" do
    params = %{}
    %{valid?: validity} = Permission.create_changeset(%Permission{}, params)
    refute validity
  end

  test "creation fails if code duplicate" do
    cset = Permission.create_changeset(%Permission{}, @params)
    assert {:ok, _} = Repo.insert(cset)

    cset = Permission.create_changeset(%Permission{}, @params)
    assert {:error, changeset} = Repo.insert(cset)
    assert %{code: ["has already been taken"]} == errors_on(changeset)
  end

  test "update successfully" do
    cset = Permission.create_changeset(%Permission{}, @params)
    assert {:ok, permission} = Repo.insert(cset)

    params = %{description: "access to order resources"}
    cset = Permission.update_changeset(permission, params)
    assert {:ok, new_permission} = Repo.update(cset)
    assert new_permission.description != permission.description
  end
end
