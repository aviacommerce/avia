defmodule Snitch.Data.Schema.UserTest do
  use ExUnit.Case
  use Snitch.DataCase

  alias Snitch.Data.Schema.User
  alias Snitch.Data.Schema.Address

  @valid_attrs %{
    first_name: "John",
    last_name: "Doe",
    email: "john@domain.com",
    password: "password123",
    password_confirmation: "password123",
    is_admin?: false
  }

  describe "Create User" do
    test "changeset with valid attributes" do
      %{valid?: validity} = User.changeset(%User{}, @valid_attrs, :create)
      assert validity
    end

    test "requires valid email" do
      params = Map.delete(@valid_attrs, :email)
      %{valid?: validity, errors: errs} = User.changeset(%User{}, params, :create)
      refute validity
      assert Keyword.get(errs, :email) == {"can't be blank", [validation: :required]}

      params = Map.update!(@valid_attrs, :email, fn _ -> "john_email.com" end)
      %{valid?: validity, errors: errs} = User.changeset(%User{}, params, :create)
      refute validity
      assert Keyword.get(errs, :email) == {"has invalid format", [validation: :format]}
    end

    test "password hash" do
      %{valid?: validity, changes: changes} = User.changeset(%User{}, @valid_attrs, :create)
      assert validity
      assert Map.has_key?(changes, :password_hash)
      refute Map.has_key?(changes, :password)
    end

    test "password must have 8 characters" do
      params = Map.update!(@valid_attrs, :password, fn _ -> "passwor" end)
      %{valid?: validity, errors: errs} = User.changeset(%User{}, params, :create)
      refute validity
      assert Keyword.get(errs, :password) == {"The password must be 8 characters long.", validation: :password}
    end

    test "password cannot be blank" do
      params = Map.update!(@valid_attrs, :password, fn _ -> "" end)
               |> Map.update!(:password_confirmation, fn _ -> "" end)
      %{valid?: validity, errors: errs} = User.changeset(%User{}, params, :create)
      refute validity
      assert Keyword.get(errs, :password) == {"can't be blank", validation: :required}
    end

    test "password confirmation required" do
      params = Map.update!(@valid_attrs, :password_confirmation, fn _ -> "password" end)
      %{valid?: validity, errors: [error | _]} = User.changeset(%User{}, params, :create)
      refute validity
      assert error == {:password_confirmation, {"does not match confirmation", [validation: :confirmation]}}
    end
  end

  describe "Update User" do
    test "changeset with valid attributes" do
      %{valid?: validity} = User.changeset(%User{}, @valid_attrs, :update)
      assert validity
    end

    test "requires valid email" do
      params = Map.delete(@valid_attrs, :email)
      %{valid?: validity, errors: errs} = User.changeset(%User{}, params, :update)
      refute validity
      assert Keyword.get(errs, :email) == {"can't be blank", [validation: :required]}

      params = Map.update!(@valid_attrs, :email, fn _ -> "john_email.com" end)
      %{valid?: validity, errors: errs} = User.changeset(%User{}, params, :update)
      refute validity
      assert Keyword.get(errs, :email) == {"has invalid format", [validation: :format]}
    end

    test "password hash" do
      %{valid?: validity, changes: changes} = User.changeset(%User{}, @valid_attrs, :update)
      assert validity
      assert Map.has_key?(changes, :password_hash)
      refute Map.has_key?(changes, :password)
    end

    test "password must have 8 characters" do
      params = Map.update!(@valid_attrs, :password, fn _ -> "passwor" end)
      %{valid?: validity, errors: errs} = User.changeset(%User{}, params, :update)
      refute validity
      assert Keyword.get(errs, :password) == {"The password must be 8 characters long.", validation: :password}
    end

    test "password cannot be blank" do
      params = Map.update!(@valid_attrs, :password, fn _ -> "" end)
               |> Map.update!(:password_confirmation, fn _ -> "" end)
      %{valid?: validity, errors: errs} = User.changeset(%User{}, params, :update)
      refute validity
      assert Keyword.get(errs, :password) == {"can't be blank", validation: :required}
    end

    test "password confirmation required" do
      params = Map.update!(@valid_attrs, :password_confirmation, fn _ -> "password" end)
      %{valid?: validity, errors: errs} = User.changeset(%User{}, params, :update)
      refute validity
      assert Keyword.get(errs, :password_confirmation) == {"does not match confirmation", [validation: :confirmation]}
    end
  end

end
