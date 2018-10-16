defmodule Snitch.Repo.Migrations.ShippingRuleIdentifierTable do
  use Ecto.Migration

  def change do
    create table("snitch_shipping_rule_identifiers") do
      add(:code, :string, null: false)
      add(:description, :string)

      timestamps()
    end
    create unique_index("snitch_shipping_rule_identifiers", [:code])
  end
end
