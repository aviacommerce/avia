defmodule Snitch.Factory.ShippingCategory do
  defmacro __using__(_opts) do
    quote do
      alias Snitch.Data.Schema.{
        ShippingCategory,
        ShippingRule,
        ShippingRuleIdentifier
      }

      def shipping_category_factory do
        %ShippingCategory{
          name: sequence(:name, &"ShippingCategory-#{&1}")
        }
      end

      def shipping_identifier_factory do
        %ShippingRuleIdentifier{
          code: :fsro
        }
      end

      def shipping_rule_factory do
        %ShippingRule{
          lower_limit: nil,
          upper_limit: nil,
          shipping_cost: Money.new!(:USD, 0),
          active?: false,
          shipping_rule_identifier: build(:shipping_identifier),
          shipping_category: build(:shipping_category)
        }
      end
    end
  end
end
