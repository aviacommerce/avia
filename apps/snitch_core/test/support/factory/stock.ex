defmodule Snitch.Factory.Stock do
  @moduledoc false

  defmacro __using__(_opts) do
    quote do
      alias Snitch.Data.Schema.{StockItem, StockLocation, StockMovement, StockTransfer}

      def stock_location_factory do
        %StockLocation{
          name: "Diagon Alley",
          admin_name: "diag-1234",
          default: false,
          address_line_1: "Street 10 London",
          address_line_2: "Gringotts Bank",
          city: "London",
          zip_code: "123456",
          phone: "1234567890",
          propagate_all_variants: false,
          backorderable_default: false,
          active: true,
          state: build(:state),
          country: build(:country)
        }
      end

      def stock_item_factory do
        %StockItem{
          count_on_hand: 1,
          backorderable: false,
          variant: build(:variant),
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
