defmodule Core.Snitch.Data.Model.LineItemTest do
  use ExUnit.Case, async: true
  use Core.Snitch.Data.Model
  import Core.Snitch.Factory

  setup :checkout_repo

  describe "line_item update_price_and_totals with valid params" do
    setup [:three_variants, :good_line_items]

    test "", context do
      %{line_items: line_items, totals: totals} = context
      priced_items = Model.LineItem.update_price_and_totals(line_items)

      assert Enum.all?(priced_items, fn x -> totals[x.variant_id] == Money.reduce(x.total) end)
    end
  end

  describe "line_item update_price_and_totals with invalid params" do
    setup [:three_variants, :bad_line_items]

    test "", context do
      %{line_items: line_items, totals: totals} = context
      priced_items = Model.LineItem.update_price_and_totals(line_items)

      assert Enum.all?(priced_items, &(not Map.has_key?(&1, :total)))
      assert Enum.all?(priced_items, &(not Map.has_key?(&1, :unit_price)))
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
          Map.put(ts, variant.id, Money.mult!(variant.cost_price, quantity))
        }
      end)

    context
    |> Map.put(:line_items, line_items)
    |> Map.put(:totals, totals)
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

    context
    |> Map.put(:line_items, line_items)
    |> Map.put(:totals, [nil, nil, nil])
  end
end

defmodule Core.Snitch.Data.Model.LineItemDocTest do
  use ExUnit.Case, async: true
  use Core.Snitch.Data.Model
  import Core.Snitch.Factory

  setup :checkout_repo

  setup do
    insert(:variant)
    :ok
  end

  doctest Model.LineItem
end
