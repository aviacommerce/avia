defmodule Snitch.Factory.Product do
  defmacro __using__(_opts) do
    quote do
      alias Snitch.Data.Schema.Product

      def product_factory do
        %Product{
          name: sequence(:name, &"Product-#{&1}"),
          description: sequence(:description, &"Product Description -#{&1}"),
          slug: sequence(:slug, &"product-#{&1}"),
          selling_price: Money.new("12.99", currency()),
          max_retail_price: Money.new("14.99", currency()),
          shipping_category: build(:shipping_category),
          inventory_tracking: :product,
          state: :active,
          tax_class: build(:tax_class)
        }
      end
    end
  end
end
