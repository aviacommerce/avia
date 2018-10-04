defmodule Snitch.Factory.ShippingCategory do
  defmacro __using__(_opts) do
    quote do
      alias Snitch.Data.Schema.ShippingCategory

      def shipping_category_factory do
        %ShippingCategory{
          name: sequence(:name, &"ShippingCategory-#{&1}")
        }
      end
    end
  end
end
