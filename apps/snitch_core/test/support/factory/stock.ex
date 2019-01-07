defmodule Snitch.Factory.Stock do
  @moduledoc false

  defmacro __using__(_opts) do
    quote do
      alias Snitch.Data.Schema.{
        StockItem,
        StockLocation,
        StockMovement,
        StockTransfer
      }

      def stock_location_factory do
        state = insert(:state)

        %StockLocation{
          name: sequence("Colosseum"),
          default: false,
          address_line_1: "Piazza del Colosseo, 1",
          address_line_2: "",
          city: "",
          zip_code: "00184",
          phone: "+39 06 3996 7700",
          propagate_all_variants: false,
          active: true,
          state: state,
          country: state.country
        }
      end

      def stock_item_factory do
        %StockItem{
          count_on_hand: 1,
          backorderable: false,
          product: build(:product, inventory_tracking: :product),
          stock_location: build(:stock_location)
        }
      end

      def stock_movement_factory do
        %StockMovement{
          quantity: 1,
          action: "",
          originator_type: "",
          stock_item: build(:stock_item)
        }
      end

      def stock_transfer_factory do
        %StockTransfer{
          reference: "",
          number: sequence(:number, &"T-something-#{&1}"),
          source: build(:stock_location),
          destination: build(:stock_location)
        }
      end
    end
  end
end
