defmodule Snitch.Data.Model.PaymentTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase

  import Snitch.Factory

  alias Snitch.Data.Model
  alias Snitch.Data.Schema

  setup do
    [
      order: insert(:order)
    ]
  end

  setup :payment_methods
  setup :payments

  test "to_subtype", context do
    %{ccd: card, chk: check} = context
    insert(:card_payment, payment_id: card.id)
    assert %Schema.CardPayment{} = Model.Payment.to_subtype(card.id)
    assert %Schema.Payment{} = Model.Payment.to_subtype(check.id)
  end
end
