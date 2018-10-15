defmodule Core.Repo.Migrations.CreateConstraintsOnPaymentSubtypes do
  use Ecto.Migration

  def change do
    create constraint("snitch_card_payments", :card_exclusivity, check: "#{ prefix() || "public" }.payment_exclusivity(payment_id, 'ccd') = 1")
  end
end
