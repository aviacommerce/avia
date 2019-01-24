defmodule Snitch.Factory.Tax do
  @moduledoc false

  defmacro __using__(_otps) do
    quote do
      alias Snitch.Data.Schema.{
        TaxClass,
        TaxConfig
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
    end
  end
end
