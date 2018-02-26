defmodule Core.Seed.PaymentMethods do
  @moduledoc """
  Seeds supported PaymentMethods.

  Snitch comes with two payment methods built-in:
  1. check or cash
  2. credit or debit cards

  ## Check or Cash

  This payment method is backed only by the `Core.Snitch.Data.Schema.Payments`
  schema.

  ## Cards

  This payment method is backed by the `Core.Snitch.Data.Schema.CardPayments`
  schema and table.

  ## Roadmap

  Snitch will support "Store Credits", which act like e-wallets for users.
  """
  use Core.Snitch.Data.Schema

  def seed!() do
    methods = [
      %{
        name: "check",
        code: "chk",
        active?: true,
        inserted_at: Ecto.DateTime.utc(),
        updated_at: Ecto.DateTime.utc()
      },
      %{
        name: "card",
        code: "ccd",
        active?: true,
        inserted_at: Ecto.DateTime.utc(),
        updated_at: Ecto.DateTime.utc()
      }
    ]

    Core.Repo.insert_all(PaymentMethod, methods, on_conflict: :nothing, conflict_target: :code)
  end
end
