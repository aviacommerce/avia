defmodule Snitch.Factory.Zone do
  @moduledoc false

  defmacro __using__(_opts) do
    quote do
      alias Snitch.Data.Schema.{Zone, StateZone, CountryZone}

      def zone_factory do
        %Zone{
          name: sequence("area", fn area_code -> "-#{area_code + 50}" end),
          description: "Does area-51 exist?"
        }
      end
    end
  end
end
