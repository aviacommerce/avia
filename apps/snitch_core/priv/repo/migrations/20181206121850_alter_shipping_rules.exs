defmodule Snitch.Repo.Migrations.AlterShippingRules do
  use Ecto.Migration

  def change do
    alter table("snitch_shipping_rules") do
      remove(:lower_limit)
      remove(:upper_limit)
      remove(:shipping_cost)
      add(:preferences, :map)
    end

    alter table("snitch_shipping_rule_identifiers") do
      modify(:description, :string, null: false)
    end
  end
end
