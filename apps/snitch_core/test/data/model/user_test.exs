defmodule Snitch.Data.Model.UserTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase

  alias Snitch.Data.Model.User
  alias Snitch.Data.Schema.User, as: UserSchema

  setup do
    valid_attrs = %{
      first_name: "John",
      last_name: "Doe",
      email: "john@domain.com",
      password: "password123",
      password_confirmation: "password123"
    }

    [valid_attrs: valid_attrs]
  end

  describe "create/1" do
    test "inserts with valid attributes", %{valid_attrs: va} do
      assert {:ok, %UserSchema{}} = User.create(va)
    end

    test "FAILS for invalid attributes", %{valid_attrs: va} do
      params = Map.update!(va, :password_confirmation, fn _ -> "does not match" end)
      assert {:error, changeset} = User.create(params)
      refute changeset.valid?
      assert %{password_confirmation: ["does not match confirmation"]} = errors_on(changeset)
    end
  end

  describe "update/2" do
    setup %{valid_attrs: va} do
      {:ok, user} = User.create(va)
      [user: user]
    end

    test "inserts with valid attributes", %{user: user} do
      %{id: expected_id} = user
      updates = %{first_name: "jordan"}
      assert {:ok, %{id: received_id}} = User.update(updates, user)
      assert expected_id == received_id
    end

    test "FAILS for invalid attributes", %{user: user} do
      updates = %{email: "john_example.com"}
      {:error, changeset} = User.update(updates, user)
      refute changeset.valid?
      assert %{email: ["has invalid format"]} = errors_on(changeset)
    end
  end

  describe "delete/2" do
    setup %{valid_attrs: va} do
      {:ok, %{id: user_id}} = User.create(va)
      [user_id: user_id]
    end

    test "FAILS to delete for invalid id" do
      assert {:error, :not_found} = User.delete(-1)
    end

    test "deletes for valid id", %{user_id: uid} do
      assert {:ok, %{id: received_id} = %UserSchema{}} = User.delete(uid)
      assert received_id == uid
    end
  end
end
