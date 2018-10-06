defmodule Snitch.Repo.Migrations.CreateHostedPayment do
  use Ecto.Migration
  alias SnitchPayments.PaymentMethodCode

  @code PaymentMethodCode.hosted_payment()

  def change do
    create table("snitch_hosted_payments", comment: "payments made via hosted payments") do
      add(:transaction_id, :string)
      add(:payment_source, :string)
      add(:raw_response, :map)
      add(:payment_id, references("snitch_payments", on_delete: :delete_all), null: false)
      timestamps()
    end

    create unique_index("snitch_hosted_payments", :payment_id)

    create constraint("snitch_hosted_payments",
      :hosted_payment_exclusivity,
      check: "#{ prefix() || "public" }.payment_exclusivity(payment_id, '#{@code}') = 1")
  end
end
