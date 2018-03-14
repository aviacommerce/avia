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
    password_confirmation: "password123"
  }

  describe "Create User" do
    test "changeset with valid attributes" do
      %{valid?: validity} = User.changeset(%User{}, @valid_attrs, :create)
      assert validity
    end

    test "email cannot be blank" do
      params = Map.delete(@valid_attrs, :email)
      %{valid?: validity, errors: errs} = User.changeset(%User{}, params, :create)
      refute validity
      assert Keyword.get(errs, :email) == {"can't be blank", [validation: :required]}
    end

    test "email must be valid" do
      params = Map.update!(@valid_attrs, :email, fn _ -> "john_email.com" end)
      %{valid?: validity, errors: errs} = User.changeset(%User{}, params, :create)
      refute validity
      assert Keyword.get(errs, :email) == {"has invalid format", [validation: :format]}
    end

    test "password is stored as hash" do
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
      %{valid?: validity, errors: [error]} = User.changeset(%User{}, params, :create)
      refute validity
      assert error == {:password_confirmation, {"does not match confirmation", [validation: :confirmation]}}
    end

    test "first name and last name cannot be blank" do
      params = Map.delete(@valid_attrs, :first_name)
      %{valid?: validity, errors: [error]} = User.changeset(%User{}, params, :create)
      refute validity
      assert error == {:first_name, {"can't be blank", [validation: :required]}}

      params = Map.delete(@valid_attrs, :last_name)
      %{valid?: validity, errors: [error]} = User.changeset(%User{}, params, :create)
      refute validity
      assert error == {:last_name, {"can't be blank", [validation: :required]}}
    end

    # test "is_admin is not required" do
    #   params = Map.delete(@valid_attrs, :is_admin)
    #   IO.inspect params
    #   %{valid?: validity} = User.changeset(%User{}, params, :create)
    #   assert validity
    # end

  end

  describe "Update User" do
    setup  do
      cs = User.changeset(%User{}, @valid_attrs, :create)
      [cs: cs]
    end

    test "requires valid email", %{cs: changeset} do
      params = %{email: "john_example.com"}
      %{valid?: validity, errors: errs} = User.changeset(changeset, params, :update)
      refute validity
      assert Keyword.get(errs, :email) == {"has invalid format", [validation: :format]}
    end

    test "password is stored as hash", %{cs: changeset} do
      params = %{password: "secret1234", password_confirmation: "secret1234"}
      %{valid?: validity, changes: changes} = User.changeset(changeset, params, :update)
      assert validity
      assert Map.has_key?(changes, :password_hash)
      refute Map.has_key?(changes, :password)
    end

    test "password must have 8 characters", %{cs: changeset} do
      params = %{password: "secret", password_confirmation: "secret"}
      %{valid?: validity, errors: [err]} = User.changeset(changeset, params, :update)
      refute validity
      assert err == {:password, {"The password must be 8 characters long.", validation: :password}}
    end

    test "password confirmation required", %{cs: changeset} do
      params = %{password: "password1234", password_confirmation: "does not match"}
      %{valid?: validity, errors: [err]} = User.changeset(changeset, params, :update)
      refute validity
      assert err == {:password_confirmation, {"does not match confirmation", [validation: :confirmation]}}
    end
  end

end
