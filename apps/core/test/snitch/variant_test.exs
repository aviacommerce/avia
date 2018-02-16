defmodule Core.Snitch.VariantTest do
  use ExUnit.Case, async: true
  alias Core.Snitch.{Variant}
  import Core.Snitch.Factory

  setup :checkout_repo

  describe "fetch selling prices of many variants" do
    setup :three_variants

    test "in one query", context do
      %{variants: vs} = context
      variant_ids = Enum.map(vs, fn x -> x.id end)

      selling_prices = Enum.map(vs, fn x -> x.cost_price end)

      computed_prices =
        variant_ids
        |> Variant.get_selling_prices()
        |> Enum.map(&Money.reduce/1)

      assert computed_prices == selling_prices
    end
  end
end
