defmodule Snitch.Seed.PaymentMethods do
  @moduledoc """
  Seeds supported PaymentMethods.

  Snitch comes with some payment methods built-in:
  1. credit or debit cards

  ## Cards

  This payment method is backed by the `Snitch.Data.Schema.CardPayments`
  schema and table.

  ## Roadmap

  Snitch will support "Store Credits", which act like e-wallets for users.
  """

  alias Snitch.Data.Schema.PaymentMethod
  alias Snitch.Core.Tools.MultiTenancy.Repo

  def seed!() do
    methods = [
      %{
        name: "check",
        code: "chk",
        active?: true,
        inserted_at: DateTime.utc_now(),
        updated_at: DateTime.utc_now()
      },
      %{
        name: "card",
        code: "ccd",
        active?: true,
        inserted_at: DateTime.utc_now(),
        updated_at: DateTime.utc_now()
      }
    ]

    Repo.insert_all(PaymentMethod, methods, on_conflict: :nothing, conflict_target: :code)
  end
end
