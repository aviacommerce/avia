defmodule Snitch.Data.Schema.RoleTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase
  alias Snitch.Data.Schema.Role

  @params %{
    name: "order_manager",
    description: "manages all orders"
  }

  test "creation fails if name empty" do
    params = Map.drop(@params, [:name])
    %{valid?: validity} = Role.create_changeset(%Role{}, params)
    refute validity
  end

  test "update successfully" do
    cset = %{valid?: validity} = Role.create_changeset(%Role{}, @params)
    assert validity
    assert {:ok, role} = Repo.insert(cset)

    params = %{description: "manage and ship all orders"}
    cset = Role.update_changeset(role, params)
    assert {:ok, new_role} = Repo.update(cset)
    assert new_role.description != role.description
  end

  test "udpate fails with empty name" do
    cset = %{valid?: validity} = Role.create_changeset(%Role{}, @params)
    assert validity
    assert {:ok, role} = Repo.insert(cset)

    params = %{name: "", description: "manage and ship all orders"}
    %{valid?: validity} = Role.update_changeset(role, params)
    refute validity
  end
end
