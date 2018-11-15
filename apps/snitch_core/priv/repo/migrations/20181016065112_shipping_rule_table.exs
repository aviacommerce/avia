defmodule Snitch.Repo.Migrations.ShippingRuleTable do
  use Ecto.Migration

  def change do
    create table("snitch_shipping_rules") do
      add(:lower_limit, :decimal)
      add(:upper_limit, :decimal)
      add(:shipping_cost, String.to_atom("money_with_currency"))
      add(:active?, :boolean)
      add(:shipping_rule_identifier_id, references("snitch_shipping_rule_identifiers", on_delete: :restrict))
      add(:shipping_category_id, references("snitch_shipping_categories", on_delete: :delete_all))
      timestamps()
    end

    create unique_index("snitch_shipping_rules",
      [:shipping_rule_identifier_id, :shipping_category_id],
      name: :unique_rule_per_category_for_identifier)
  end
end
