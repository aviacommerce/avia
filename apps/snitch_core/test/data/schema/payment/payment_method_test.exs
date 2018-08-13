defmodule Snitch.Data.Schema.PaymentMethodTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase

  alias Snitch.Data.Schema.PaymentMethod

  test "PaymentMethod `:update` ignores changes to `:code`" do
    create_params = %{name: "card-payments", code: "ccd", provider: PayuBiz}
    card_method = PaymentMethod.create_changeset(%PaymentMethod{}, create_params)
    assert {:ok, _} = Repo.insert(card_method)

    update_params = %{name: "by card", active?: false}

    %Ecto.Changeset{changes: changes} =
      PaymentMethod.update_changeset(%PaymentMethod{}, update_params)

    assert changes == update_params
  end
end
