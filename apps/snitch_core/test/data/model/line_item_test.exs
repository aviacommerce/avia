defmodule Snitch.Data.Model.LineItemTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase

  import Snitch.Factory
  import Mox

  alias Snitch.Data.Model.LineItem

  describe "with valid params" do
    setup [:variants, :good_line_items]

    test "update_price_and_totals/1", context do
      %{line_items: line_items, totals: totals} = context
      priced_items = LineItem.update_price_and_totals(line_items)
      assert Enum.all?(priced_items, fn x -> totals[x.variant_id] == Money.reduce(x.total) end)
    end

    test "compute_totals/1", context do
      %{line_items: line_items} = context
      priced_items = LineItem.update_price_and_totals(line_items)
      assert %Money{} = LineItem.compute_total(priced_items)
    end
  end

  describe "with invalid params" do
    setup [:variants, :bad_line_items]

    test "update_price_and_totals/1", context do
      %{line_items: line_items} = context
      priced_items = LineItem.update_price_and_totals(line_items)

      assert Enum.all?(priced_items, &(not Map.has_key?(&1, :total)))
      assert Enum.all?(priced_items, &(not Map.has_key?(&1, :unit_price)))
    end
  end

  describe "compute_total/1 with empty list" do
    setup :verify_on_exit!

    test "when default currency is set" do
      expect(Snitch.Tools.DefaultsMock, :fetch, fn :currency -> {:ok, :INR} end)
      assert Money.zero(:INR) == LineItem.compute_total([])
    end

    test "when default currency is not set" do
      expect(Snitch.Tools.DefaultsMock, :fetch, fn :currency -> {:error, "whatever"} end)

      assert_raise RuntimeError, "whatever", fn ->
        LineItem.compute_total([])
      end
    end
  end

  defp good_line_items(context) do
    %{variants: vs} = context
    quantities = Stream.cycle([2])

    {line_items, totals} =
      vs
      |> Stream.zip(quantities)
      |> Enum.reduce({[], %{}}, fn {variant, quantity}, {ls, ts} ->
        {
          [%{variant_id: variant.id, quantity: quantity} | ls],
          Map.put(ts, variant.id, Money.mult!(variant.selling_price, quantity))
        }
      end)

    [line_items: line_items, totals: totals]
  end

  defp bad_line_items(context) do
    %{variants: [one, two, three]} = context
    variants = [%{one | id: -1}, two, %{three | id: nil}]
    quantities = [2, nil, 2]

    line_items =
      variants
      |> Stream.zip(quantities)
      |> Enum.map(fn {variant, quantity} ->
        %{variant_id: variant.id, quantity: quantity}
      end)

    [line_items: line_items, totals: [nil, nil, nil]]
  end
end

defmodule Snitch.Data.Model.LineItemDocTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase

  import Snitch.Factory

  alias Snitch.Data.Model

  setup do
    insert(:variant)
    :ok
  end

  doctest Snitch.Data.Model.LineItem
end
