defmodule Snitch.Factory.Taxonomy do
  defmacro __using__(_otps) do
    quote do
      alias Snitch.Data.Schema.{
        Taxon,
        Taxonomy
      }

      def taxonomy_factory() do
        %Taxonomy{
          name: sequence("Taxonomy")
        }
      end

      def taxon_factory() do
        %Taxon{
          name: sequence("Taxon")
        }
      end
    end
  end
end
