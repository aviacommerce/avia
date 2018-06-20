defmodule Snitch.Domain.AccountTest do
  use ExUnit.Case
  use Snitch.DataCase
  import Snitch.Factory

  alias Snitch.Domain.Account

  setup do
    role = insert(:role)

    valid_attrs = %{
      email: "superman@himalya.com",
      first_name: "Super",
      last_name: "Man",
      password: "supergirl",
      password_confirmation: "supergirl",
      role_id: role.id
    }

    [valid_attrs: valid_attrs]
  end

  test "register user successfully", %{valid_attrs: va} do
    {:ok, _} = Account.register(va)
  end

  test "registration failed missing params", %{valid_attrs: va} do
    params = Map.drop(va, [:email])
    {:error, changeset} = Account.register(params)
    assert %{email: ["can't be blank"]} = errors_on(changeset)
  end

  test "user authenticated successfully", %{valid_attrs: va} do
    assert {:ok, _} = Account.register(va)
    {:ok, _} = Account.authenticate(va.email, va.password)
  end

  test "user unauthenticated bad email", %{valid_attrs: va} do
    assert {:ok, _} = Account.register(va)
    {:error, message} = Account.authenticate("tony@stark.com", va.password)
    assert message == :not_found
  end

  test "user unauthenticated bad password", %{valid_attrs: va} do
    assert {:ok, _} = Account.register(va)
    {:error, message} = Account.authenticate(va.email, "catwoman")
    assert message == :not_found
  end
end
