defmodule Snitch.Data.Model.PaymentTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase

  import Snitch.Factory

  alias Snitch.Data.Model
  alias Snitch.Data.Schema

  setup :user_with_address
  setup :an_order
  setup :payment_methods
  setup :payments

  test "to_subtype", context do
    %{ccd: card, chk: check} = context

    assert %Schema.CardPayment{} = Model.Payment.to_subtype(card.id)
    assert %Schema.Payment{} = Model.Payment.to_subtype(check.id)
  end
end
