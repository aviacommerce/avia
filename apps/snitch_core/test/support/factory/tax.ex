defmodule Snitch.Factory.Tax do
  @moduledoc false

  defmacro __using__(_otps) do
    quote do
      alias Snitch.Data.Schema.{
        TaxClass,
        TaxConfig,
        TaxZone,
        TaxRate,
        TaxRateClassValue
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
          is_default: false,
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

      def tax_rate_class_value_factory() do
        %TaxRateClassValue{
          percent_amount: 2,
          tax_class: build(:tax_class),
          tax_rate: build(:tax_rate)
        }
      end

      def setup_tax_with_zone_and_rates(tax_rate_values, states) do
        zone = insert(:zone, zone_type: "S")
        zone_c = insert(:zone, zone_type: "C")

        Enum.each(states, fn state ->
          insert(:state_zone_member, zone: zone, state: state)
        end)

        default_state = List.first(states)

        insert(:tax_config,
          default_state: default_state,
          default_country: default_state.country,
          calculation_address_type: :shipping_address,
          included_in_price?: true,
          shipping_tax: tax_rate_values.shipping_tax.class
        )

        tax_zone = insert(:tax_zone, zone: zone)
        _default_tax_zone = insert(:tax_zone, zone: zone_c, is_default: true)

        tax_rate = insert(:tax_rate, tax_zone: tax_zone)

        Enum.map(tax_rate_values, fn {_key, %{class: class, percent: percent}} ->
          insert(:tax_rate_class_value,
            tax_rate: tax_rate,
            tax_class: class,
            percent_amount: percent
          )
        end)
      end
    end
  end
end
