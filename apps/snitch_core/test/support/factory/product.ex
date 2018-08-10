defmodule Snitch.Factory.Product do
  defmacro __using__(_opts) do
    quote do
      alias Snitch.Data.Schema.Product

      def product_factory do
        %Product{
          name: sequence(:name, &"Product-#{&1}"),
          description: sequence(:description, &"Product Description -#{&1}"),
          slug: sequence(:slug, &"product-#{&1}")
        }
      end
    end
  end
end
