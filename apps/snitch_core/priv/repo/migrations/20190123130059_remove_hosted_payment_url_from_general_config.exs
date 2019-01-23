defmodule Snitch.Repo.Migrations.RemoveHostedPaymentUrlFromGeneralConfig do
  use Ecto.Migration

  def change do
    alter table("snitch_general_configurations") do
      remove :hosted_payment_url
    end
  end
end
