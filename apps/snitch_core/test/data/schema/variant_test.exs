defmodule Snitch.Data.Schema.VariantTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase

  import Snitch.Factory

  alias Snitch.Data.Schema.Variant

  describe "(in one query) fetch selling prices" do
    setup :variants

    test "of valid variants", context do
      %{variants: vs} = context
      variant_ids = Enum.map(vs, fn x -> x.id end)

      selling_prices = Enum.reduce(vs, %{}, fn x, acc -> Map.put(acc, x.id, x.cost_price) end)

      computed_prices =
        variant_ids
        |> Variant.get_selling_prices()
        |> Enum.reduce(%{}, fn {id, x}, acc -> Map.put(acc, id, Money.reduce(x)) end)

      assert computed_prices == selling_prices
    end

    test "of invalid variants" do
      variant_ids = [-1]

      computed_prices =
        variant_ids
        |> Variant.get_selling_prices()
        |> Enum.reduce(%{}, fn {id, x}, acc -> Map.put(acc, id, Money.reduce(x)) end)

      assert :error = Map.fetch(computed_prices, -1)
    end
  end
end
