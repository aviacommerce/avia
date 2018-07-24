defmodule Snitch.Factory.Address do
  @moduledoc false

  defmacro __using__(_opts) do
    quote do
      alias Snitch.Data.Schema.{Address, Country, State}

      def state_factory do
        %State{
          name: "California",
          code: sequence("US-CA"),
          country: build(:country)
        }
      end

      def country_factory do
        %Country{
          iso_name: sequence("UNITED STATES"),
          iso: sequence("U"),
          iso3: sequence("US"),
          name: sequence("United States"),
          numcode: sequence("840"),
          states_required: true
        }
      end

      def address_factory do
        state = insert(:state)

        %Address{
          first_name: "Tony",
          last_name: "Stark",
          address_line_1: "10-8-80 Malibu Point",
          zip_code: "90265",
          city: "Malibu",
          phone: "1234567890",
          state: state,
          country: state.country
        }
      end

      def states(context) do
        country = insert(:country)
        count = Map.get(context, :state_count, 1)
        [states: insert_list(count, :state, country: country)]
      end

      def countries(context) do
        count = Map.get(context, :country_count, 1)
        [countries: insert_list(count, :country)]
      end
    end
  end
end
