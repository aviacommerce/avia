defmodule Snitch.Factory.ShippingCategory do
  defmacro __using__(_opts) do
    quote do
      alias Snitch.Data.Schema.{
        ShippingCategory,
        ShippingRule,
        ShippingRuleIdentifier
      }

      alias Snitch.Core.Tools.MultiTenancy.Repo

      def shipping_category_factory do
        %ShippingCategory{
          name: sequence(:name, &"ShippingCategory-#{&1}")
        }
      end

      def shipping_identifier_factory do
        %ShippingRuleIdentifier{
          code: :fso,
          description: "free shipping for order"
        }
      end

      def shipping_rule_factory do
        %ShippingRule{
          active?: false,
          shipping_rule_identifier: build(:shipping_identifier),
          shipping_category: build(:shipping_category),
          preferences: %{}
        }
      end

      def package_with_shipping_rule(context, quantity, rule_manifest, preference_manifest) do
        %{embedded_shipping_methods: embedded_shipping_methods} = context

        # setup stock for product
        stock_item = insert(:stock_item, count_on_hand: 20)

        # setup shipping category, identifier, rules
        shipping_identifier =
          insert(:shipping_identifier,
            code: rule_manifest.code,
            description: rule_manifest.description
          )

        shipping_category = insert(:shipping_category)

        shipping_rule =
          insert(:shipping_rule,
            active?: true,
            preferences: preference_manifest,
            shipping_rule_identifier: shipping_identifier,
            shipping_category: shipping_category
          )

        # make order and it's packages
        product = stock_item.product
        order = insert(:order, state: "delivery")
        line_item = insert(:line_item, order: order, product: product, quantity: quantity)

        package =
          insert(:package,
            shipping_methods: embedded_shipping_methods,
            order: order,
            items: [],
            origin: stock_item.stock_location,
            shipping_category: shipping_category
          )

        _package_item =
          insert(:package_item,
            quantity: quantity,
            product: product,
            line_item: line_item,
            package: package
          )

        package =
          Snitch.Data.Schema.Package
          |> Repo.get(package.id)
          |> Repo.preload(:items)

        shipping_rule = Repo.get(Snitch.Data.Schema.ShippingRule, shipping_rule.id)

        %{
          package: package,
          rule: shipping_rule
        }
      end
    end
  end
end
