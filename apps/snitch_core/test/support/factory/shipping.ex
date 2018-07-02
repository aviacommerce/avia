defmodule Snitch.Factory.Shipping do
  @moduledoc false

  defmacro __using__(_opts) do
    quote do
      alias Snitch.Data.Schema.{Package, PackageItem, ShippingCategory, ShippingMethod}
      alias Snitch.Data.Schema.Embedded.ShippingMethod, as: EmbeddedShippingMethod

      def shipping_method_factory do
        %ShippingMethod{
          slug: sequence("shipping_method"),
          name: sequence("hyperloop"),
          description: "Brought to you by spacex!"
        }
      end

      def embedded_shipping_method_factory do
        %EmbeddedShippingMethod{
          id: sequence(:id, &(&1 + 1)),
          slug: sequence("shipping_method"),
          name: sequence(:name, &"method-#{&1}"),
          description: "Snitch revolution",
          cost: Money.new(3, :USD)
        }
      end

      def package_item_factory do
        %PackageItem{
          state: "pending",
          quantity: 1,
          delta: 0,
          variant: build(:variant),
          line_item: build(:line_item)
        }
      end

      def package_factory do
        %Package{
          number: sequence("package_"),
          state: "ready",
          shipped_at: nil,
          tracking: %{id: "some_tracking_id"},
          shipping_methods: [],
          cost: Money.new(0, :USD),
          total: Money.new(0, :USD),
          tax_total: Money.new(0, :USD),
          adjustment_total: Money.new(0, :USD),
          promo_total: Money.new(0, :USD),
          order: build(:order, user: build(:user)),
          origin: build(:stock_location),
          shipping_category: build(:shipping_category)
        }
      end

      def shipping_category_factory do
        %ShippingCategory{
          name: sequence("shipping_category")
        }
      end

      def shipping_methods(%{zones: zones} = context) do
        sm_count = Map.get(context, :shipping_method_count, 0)
        categories = Map.get(context, :shipping_categories, [])

        [
          shipping_methods:
            insert_list(sm_count, :shipping_method, zones: zones, shipping_categories: categories)
        ]
      end

      def embedded_shipping_methods(%{shipping_methods: shipping_methods}) do
        [
          embedded_shipping_methods:
            Enum.map(shipping_methods, fn %{id: id} ->
              %{build(:embedded_shipping_method) | id: id}
            end)
        ]
      end

      def shipping_categories(context) do
        sc_count = Map.get(context, :shipping_category_count, 0)

        [
          shipping_categories: insert_list(sc_count, :shipping_category)
        ]
      end
    end
  end
end
