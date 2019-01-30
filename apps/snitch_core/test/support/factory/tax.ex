defmodule Snitch.Factory.Tax do
  @moduledoc false

  defmacro __using__(_otps) do
    quote do
      alias Snitch.Data.Schema.{
        TaxClass,
        TaxConfig,
        TaxZone,
        TaxRate
      }

      def tax_class_factory() do
        %TaxClass{
          name: sequence(:tax_class_name, &"A_GEN_#{&1}"),
          is_default: false
        }
      end

      def tax_config_factory() do
        %TaxConfig{
          label: "Sales Tax",
          included_in_price?: false,
          calculation_address_type: :shipping_address,
          preferences: %{},
          shipping_tax: build(:tax_class),
          gift_tax: build(:tax_class),
          default_country: build(:country),
          default_state: build(:state)
        }
      end

      def tax_zone_factory() do
        %TaxZone{
          name: sequence(:tax_zone_name, fn id -> "taxzone_#{id}" end),
          is_active?: false,
          zone: build(:zone)
        }
      end

      def tax_rate_factory() do
        %TaxRate{
          name: sequence(:tax_rate_name, fn id -> "taxrate_#{id}" end),
          tax_zone: build(:tax_zone),
          is_active?: true,
          priority: 0
        }
      end
    end
  end
end
