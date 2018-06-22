defmodule Snitch.Domain.Splitters.Weight do
  @moduledoc """
  Splitter to split that packages based on weight
  """
  # TODO https://www.pivotaltracker.com/story/show/157818616
  @bin_threshold Decimal.new(150)

  def split([]), do: []

  def split(packages) do
    packages
    |> Enum.map(&sort_items_by_weight/1)
    |> Enum.map(fn package ->
      package.items
      |> Enum.reduce([], &add_item_to_bin/2)
      |> Enum.map(fn items -> %{package | items: items, variants: update_variants(items)} end)
    end)
    |> List.flatten()
  end

  defp update_variants(items) do
    items
    |> Enum.map(fn %{variant: v} -> v.id end)
    |> MapSet.new()
  end

  defp sort_items_by_weight(package) do
    sorted_line_items = Enum.sort(package.items, &compare_weight/2)

    %{package | items: sorted_line_items}
  end

  defp add_item_to_bin(item, []) do
    case find_item_action(item, []) do
      :split_item ->
        split_item(item)

      _ ->
        [[item]]
    end
  end

  defp add_item_to_bin(item, acc), do: put_in_bin(item, acc, acc)

  defp put_in_bin(item, [], acc), do: [[item] | acc]

  defp put_in_bin(item, [first_bin | rest_bins], acc) do
    case find_item_action(item, first_bin) do
      :split_item ->
        Enum.concat(split_item(item), acc)

      :next_bin ->
        put_in_bin(item, rest_bins, acc)

      :insert_in_bin ->
        [[item | first_bin] | rest_bins]
    end
  end

  defp find_item_action(item, current_bin) do
    item_weight = get_item_weight(item)

    bin_weight =
      Enum.reduce(current_bin, Decimal.new(0), fn item, acc ->
        Decimal.add(get_item_weight(item), acc)
      end)

    next_total = Decimal.add(bin_weight, item_weight)

    if Decimal.cmp(item_weight, @bin_threshold) == :gt do
      :split_item
    else
      case Decimal.cmp(next_total, @bin_threshold) do
        :gt -> :next_bin
        _ -> :insert_in_bin
      end
    end
  end

  defp split_item(item) do
    max_quantity_per_item =
      @bin_threshold
      |> Decimal.div_int(item.variant.weight)
      |> Decimal.to_integer()

    total_bins = div(item.line_item.quantity, max_quantity_per_item)
    remaining_quantity = rem(item.line_item.quantity, max_quantity_per_item)

    build_item(
      item,
      [],
      total_bins + remaining_quantity,
      max_quantity_per_item,
      item.quantity,
      item.delta
    )
  end

  defp build_item(_, acc, 0, _, _, _), do: acc

  defp build_item(item, acc, item_count, max_quantity, current_stock, current_delta) do
    quantity = get_quantity_to_update(current_stock, max_quantity)

    delta =
      if quantity < max_quantity and current_delta > 0 do
        min(current_delta, max_quantity - quantity)
      else
        0
      end

    current_item =
      item
      |> Map.put(:quantity, quantity)
      |> Map.put(:delta, delta)

    build_item(
      item,
      [[current_item] | acc],
      item_count - 1,
      max_quantity,
      current_stock - quantity,
      current_delta - delta
    )
  end

  defp get_quantity_to_update(current_stock, max_quantity) when current_stock >= max_quantity do
    max_quantity
  end

  defp get_quantity_to_update(current_stock, max_quantity) do
    rem(current_stock, max_quantity)
  end

  defp get_item_weight(item) do
    Decimal.mult(item.variant.weight, item.line_item.quantity)
  end

  defp compare_weight(item1, item2) do
    weight1 = item1.variant.weight
    weight2 = item2.variant.weight

    case Decimal.cmp(weight1, weight2) do
      :gt -> true
      _ -> false
    end
  end
end
