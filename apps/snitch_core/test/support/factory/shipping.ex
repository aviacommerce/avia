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
          product: build(:product),
          line_item: build(:line_item),
          backordered?: false
        }
      end

      def package_factory do
        %Package{
          number: sequence("package_"),
          state: "ready",
          shipped_at: nil,
          tracking: %{id: "some_tracking_id"},
          shipping_methods: [],
          order: build(:order, user: build(:user)),
          origin: build(:stock_location),
          items: [],
          shipping_category: build(:shipping_category)
        }
      end

      def shipping_category_factory do
        %ShippingCategory{
          name: sequence("shipping_category")
        }
      end

      def shipment_factory do
        %{
          items: [
            %{
              line_item: insert(:line_item),
              variant: build(:variant),
              delta: 0,
              quantity: 4,
              state: :fulfilled
            }
          ],
          origin: build(:stock_location),
          category: build(:shipping_category),
          zones: [build(:zone, zone_type: "C")],
          shipping_methods: [build(:shipping_method)],
          shipping_costs: [Money.new(0, :USD)],
          backorders?: false,
          variants: MapSet.new([0])
        }
      end

      def shipment!(%{line_items: [line_item], variants: [v]} = context) do
        [
          shipment: %{
            items: [
              %{
                line_item: line_item,
                variant: v,
                delta: 0,
                quantity: line_item.quantity,
                state: :fulfilled,
                tax: Money.zero(:USD)
              }
            ],
            origin: insert(:stock_location),
            category: insert(:shipping_category),
            zones: [insert(:zone, zone_type: "C")],
            shipping_methods: [insert(:shipping_method)],
            shipping_costs: [Money.new(0, :USD)],
            backorders?: false,
            variants: MapSet.new([v.id])
          }
        ]
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
