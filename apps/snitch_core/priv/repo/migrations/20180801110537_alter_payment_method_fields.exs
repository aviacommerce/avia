defmodule Snitch.Repo.Migrations.AlterPaymentMethodFields do
  use Ecto.Migration

  def change do
    alter table("snitch_payment_methods") do
      add(:description, :string)
      add(:live_mode?, :boolean, default: false)
      add(:provider, :string, null: false)
      add(:preferences, :map)
    end

    create unique_index("snitch_payment_methods", :name)
    drop index("snitch_payment_methods", [:code])
  end
end
