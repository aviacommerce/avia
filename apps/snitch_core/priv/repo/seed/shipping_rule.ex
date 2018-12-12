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
    description: '',
    inserted_at: DateTime.utc_now(),
    updated_at: DateTime.utc_now()
  }

  @shipping_rule %{
    active?: false,
    shipping_rule_identifier_id: nil,
    shipping_category_id: nil,
    preferences: nil,
    inserted_at: DateTime.utc_now(),
    updated_at: DateTime.utc_now()
  }

  def seed!() do
    all_identifiers = seed_shipping_rule_identifiers()
    all_categories = Repo.all(ShippingCategory)
    seed_shipping_rules(all_identifiers, all_categories)
  end

  defp seed_shipping_rule_identifiers() do
    codes_with_description = identifier_manifest()

    identifiers =
      Enum.map(
        codes_with_description,
        fn {key, value} ->
          %{@shipping_rule_identifier | code: key, description: value.description}
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
                  shipping_category_id: category.id,
                  preferences: get_identifier_preference(identifier)
              }
              | acc
            ]
          end)

        list ++ acc
      end)

    Repo.insert_all(ShippingRule, rules, on_conflict: :nothing, returning: true)
  end

  defp identifier_manifest() do
    %{
      fso: %{
        description: "free shipping for order",
        module: Snitch.Data.Schema.ShippingRule.OrderFree,
        preferences: %{}
      },
      fsoa: %{
        description: "free shipping above specified amount",
        module: Snitch.Data.Schema.ShippingRule.OrderConditionalFree,
        preferences: %{amount: Decimal.new(0)}
      },
      fsrp: %{
        description: "fixed shipping rate per product",
        module: Snitch.Data.Schema.ShippingRule.ProductFlatRate,
        preferences: %{cost_per_item: Decimal.new(0)}
      },
      ofr: %{
        description: "fixed shipping rate for order",
        module: Snitch.Data.Schema.ShippingRule.OrderFlatRate,
        preferences: %{cost: Decimal.new(0)}
      }
    }
  end

  defp get_identifier_preference(identifier) do
    all_identifiers = identifier_manifest()
    identifier = all_identifiers[identifier.code]

    identifier.preferences
  end
end
