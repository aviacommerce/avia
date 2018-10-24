defmodule Snitch.Seed.ShippingRules do
  @moduledoc false

  alias Snitch.Data.Schema.{
    ShippingRule,
    ShippingRuleIdentifier,
    ShippingCategory
  }

  alias Snitch.Core.Tools.MultiTenancy.Repo

  @shipping_rule_identifier %{
    code: nil,
    inserted_at: DateTime.utc_now(),
    updated_at: DateTime.utc_now()
  }

  @shipping_rule %{
    active?: false,
    shipping_rule_identifier_id: nil,
    shipping_category_id: nil,
    inserted_at: DateTime.utc_now(),
    updated_at: DateTime.utc_now(),
    shipping_cost: Money.new!(:USD, 0)
  }

  def seed!() do
    all_identifiers = seed_shipping_rule_identifiers()
    all_categories = Repo.all(ShippingCategory)
    seed_shipping_rules(all_identifiers, all_categories)
  end

  defp seed_shipping_rule_identifiers() do
    codes = ShippingRuleIdentifier.codes()

    identifiers =
      Enum.map(
        codes,
        fn code ->
          %{@shipping_rule_identifier | code: code}
        end
      )

    {_, _} =
      Repo.insert_all(ShippingRuleIdentifier, identifiers, on_conflict: :nothing, returning: false)

    Repo.all(ShippingRuleIdentifier)
  end

  def seed_shipping_rules(identifiers, categories) do
    rules =
      Enum.reduce(categories, [], fn category, acc ->
        list =
          Enum.reduce(identifiers, [], fn identifier, acc ->
            [
              %{
                @shipping_rule
                | shipping_rule_identifier_id: identifier.id,
                  shipping_category_id: category.id
              }
              | acc
            ]
          end)

        list ++ acc
      end)

    Repo.insert_all(ShippingRule, rules, on_conflict: :nothing, returning: true)
  end
end
