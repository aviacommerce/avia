defmodule Snitch.Factory.Shipping do
  @moduledoc false

  defmacro __using__(_opts) do
    quote do
      alias Snitch.Data.Schema.{ShippingMethod, ShipmentUnit}

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

      def shipping_methods(%{zones: zones} = context) do
        sm_count = Map.get(context, :shipping_method_count, 0)

        [
          shipping_methods: insert_list(sm_count, :shipping_method, zones: zones)
        ]
      end
    end
  end
end
