defmodule Core.Snitch.Data.Schema.PaymentMethodTest do
  use ExUnit.Case, async: true
  use Core.Snitch.Data.Schema

  import Core.Snitch.Factory

  setup :checkout_repo

  test "PaymentMethods must have unique code" do
    params = %{name: "card-payments", code: "ccd"}
    card_method = PaymentMethod.changeset(%PaymentMethod{}, params, :create)
    assert %Ecto.Changeset{valid?: true} = card_method
    assert {:ok, _} = Core.Repo.insert(card_method)
    assert {:error, %Ecto.Changeset{errors: errors}} = Core.Repo.insert(card_method)
    assert errors == [code: {"has already been taken", []}]
  end

  test "PaymentMethod `:update` ignores changes to `:code`" do
    create_params = %{name: "card-payments", code: "ccd"}
    card_method = PaymentMethod.changeset(%PaymentMethod{}, create_params, :create)
    assert {:ok, _} = Core.Repo.insert(card_method)

    update_params = %{name: "by card", active?: false}

    %Ecto.Changeset{changes: changes} =
      PaymentMethod.changeset(%PaymentMethod{}, update_params, :update)

    assert changes == update_params
  end
end
