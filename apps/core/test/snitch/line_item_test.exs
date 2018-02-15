defmodule Core.Snitch.LineItemTest do
  use ExUnit.Case, async: true
  alias Core.Snitch.{LineItem}
  import Core.Snitch.Factory

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Core.Repo)
  end

  describe "line_items" do
    setup :three_variants

    test "computes prices correctly from changesets", context do
      %{variants: vs} = context
      quantities = Stream.cycle([2])
      variant_ids = Stream.map(vs, fn x -> x.id end)

      total =
        vs
        |> Stream.map(fn v -> v.cost_price end)
        |> Stream.zip(quantities)
        |> Stream.map(fn {price, quantity} -> Money.mult!(price, quantity) end)
        |> Enum.reduce(&Money.add!/2)

      line_item_changesets =
        variant_ids
        |> Stream.zip(quantities)
        |> Enum.map(fn {variant_id, quantity} ->
          LineItem.build(variant_id, quantity)
        end)

      {computed_total, _} = LineItem.compute_prices(line_item_changesets)
      assert Money.reduce(computed_total) == total
    end
  end
end
