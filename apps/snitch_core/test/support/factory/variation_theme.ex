defmodule Snitch.Factory.VariationTheme do
  defmacro __using__(_opts) do
    quote do
      alias Snitch.Data.Schema.VariationTheme

      def variation_theme_factory do
        %VariationTheme{
          name: sequence(:name, &"Theme-#{&1}")
        }
      end
    end
  end
end
