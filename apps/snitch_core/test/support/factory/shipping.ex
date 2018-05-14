defmodule Snitch.Factory.Shipping do
  @moduledoc false

  defmacro __using__(_opts) do
    quote do
      alias Snitch.Data.Schema.{ShippingMethod, ShipmentUnit, ShippingCategory}

      def shipping_method_factory do
        %ShippingMethod{
          slug: sequence("shipping_method"),
          name: sequence("hyperloop"),
          description: "Brought to you by spacex!"
        }
      end

      def shipment_unit_factory do
        %ShipmentUnit{
          quantity: 1,
          state: "pending",
          variant: build(:variant),
          line_item: build(:line_item)
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

      def shipping_categories(context) do
        sc_count = Map.get(context, :shipping_category_count, 0)

        [
          shipping_categories: insert_list(sc_count, :shipping_category)
        ]
      end
    end
  end
end
