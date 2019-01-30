defmodule Snitch.Data.Schema.UserTest do
  use ExUnit.Case
  use Snitch.DataCase

  import Snitch.Factory
  import Ecto.Changeset, only: [apply_changes: 1]

  alias Snitch.Data.Schema.User

  @valid_attrs %{
    first_name: "John",
    last_name: "Doe",
    email: "john@domain.com",
    password: "password123",
    password_confirmation: "password123",
    role_id: 1
  }

  describe "Create User" do
    test "changeset with valid attributes" do
      %{valid?: validity} = User.create_changeset(%User{}, @valid_attrs)
      assert validity
    end

    test "email cannot be blank" do
      params = Map.delete(@valid_attrs, :email)
      cs = %{valid?: validity} = User.create_changeset(%User{}, params)
      refute validity
      assert %{email: ["can't be blank"]} = errors_on(cs)
    end

    test "email must be valid" do
      params = Map.update!(@valid_attrs, :email, fn _ -> "john_email.com" end)
      cs = %{valid?: validity} = User.create_changeset(%User{}, params)
      refute validity
      assert %{email: ["has invalid format"]} = errors_on(cs)
    end

    test "if an email is already taken" do
      user = insert(:user)
      params = Map.update!(@valid_attrs, :email, fn _ -> user.email end)

      cs = %{valid?: validity} = User.create_changeset(%User{}, params)
      refute validity
      assert %{email: ["Email already in use"]} = errors_on(cs)
    end

    test "password is stored as hash" do
      %{valid?: validity, changes: changes} = User.create_changeset(%User{}, @valid_attrs)
      assert validity
      assert Map.has_key?(changes, :password_hash)
      refute Map.has_key?(changes, :password)
    end

    test "password must have 8 characters" do
      params = Map.update!(@valid_attrs, :password, fn _ -> "passwor" end)
      cs = %{valid?: validity} = User.create_changeset(%User{}, params)
      refute validity
      assert %{password: ["should be at least 8 character(s)"]} = errors_on(cs)
    end

    test "password cannot be blank" do
      params = Map.update!(@valid_attrs, :password, fn _ -> "" end)
      cs = %{valid?: validity} = User.create_changeset(%User{}, params)
      refute validity
      assert %{password: ["can't be blank"]} = errors_on(cs)
    end

    test "password confirmation required" do
      params = Map.update!(@valid_attrs, :password_confirmation, fn _ -> "password" end)
      cs = %{valid?: validity} = User.create_changeset(%User{}, params)
      refute validity
      assert %{password_confirmation: ["does not match confirmation"]} = errors_on(cs)
    end

    test "first name and last name cannot be blank" do
      params = Map.delete(@valid_attrs, :first_name)
      cs = %{valid?: validity} = User.create_changeset(%User{}, params)
      refute validity
      assert %{first_name: ["can't be blank"]} = errors_on(cs)

      params = Map.delete(@valid_attrs, :last_name)
      cs = %{valid?: validity} = User.create_changeset(%User{}, params)
      refute validity
      assert %{last_name: ["can't be blank"]} = errors_on(cs)
    end
  end

  describe "Update User" do
    setup do
      [
        user:
          %User{}
          |> User.create_changeset(@valid_attrs)
          |> apply_changes()
      ]
    end

    test "valid attributes", %{user: user} do
      params = %{email: "john@example.com"}
      %{valid?: validity} = User.update_changeset(user, params)
      assert validity
    end

    test "requires valid email", %{user: user} do
      params = %{email: "john_example.com"}
      cs = %{valid?: validity} = User.update_changeset(user, params)
      refute validity
      assert %{email: ["has invalid format"]} = errors_on(cs)
    end

    test "password is stored as hash", %{user: user} do
      params = %{password: "secret1234", password_confirmation: "secret1234"}
      %{valid?: validity, changes: changes} = User.update_changeset(user, params)
      assert validity
      assert Map.has_key?(changes, :password_hash)
      refute Map.has_key?(changes, :password)
    end

    test "password must have 8 characters", %{user: user} do
      params = %{password: "secret", password_confirmation: "secret"}
      cs = %{valid?: validity} = User.update_changeset(user, params)
      refute validity
      assert %{password: ["should be at least 8 character(s)"]} = errors_on(cs)
    end

    test "password confirmation required", %{user: user} do
      params = %{password: "password1234", password_confirmation: "does not match"}
      cs = %{valid?: validity} = User.update_changeset(user, params)
      refute validity
      assert %{password_confirmation: ["does not match confirmation"]} = errors_on(cs)
    end
  end
end
