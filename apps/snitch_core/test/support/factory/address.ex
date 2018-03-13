defmodule Snitch.AddressFactory do
  @moduledoc false

  defmacro __using__(_opts) do
    quote do
      alias Snitch.Data.Schema.{State, Country, Address}

      def state_factory do
        %State{
          name: "London",
          abbr: "LDN",
          country: build(:country)
        }
      end

      def country_factory do
        %Country{
          iso_name: "LDN",
          iso: "+45",
          iso3: "+45",
          name: "United Kingdom",
          numcode: "+45",
          states_required: false
        }
      end

      def address_factory do
        %Address{
          first_name: sequence(:first_name, &"Diagon-#{&1}"),
          last_name: sequence(:last_name, &"Alley-#{&1}"),
          address_line_1: "Near",
          address_line_2: "Gringotts",
          city: "London",
          zip_code: "123456",
          phone: "987654321",
          alternate_phone: "0987654321"
        }
      end
    end
  end
end
