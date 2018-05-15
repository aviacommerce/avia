defmodule Snitch.Domain.Shipment do
  @moduledoc """
  The coordinator, packer, estimator and prioritizer -- all in one.

  The package struct:
  ```
  %{
    hash: TBD
    items: [
      %{
        variant: %Variant{},
        line_item: %LineItem{},
        variant_id: 0,
        state: :fulfilled | :backorder,
        quantity: 0,
        delta: line_item.quantity - package_quantity
       }
    ],
    zone: %Zone{}
    shipping_methods: [%ShippingMethod{}],
    origin: %StockLocation{}, # the `:stock_items` will not be "loaded"
    category: %ShippingCategory{},
    backorders?: true | false
   }
  ```
  """

  use Snitch.Domain

  alias Snitch.Data.Schema.{Order}
  alias Snitch.Data.Model.{StockLocation, Variant}

  def default_packages(%Order{} = order) do
    order = Repo.preload(order, line_items: [], shipping_address: [:state, :country])
    variant_ids = Enum.map(order.line_items, fn %{variant_id: id} -> id end)
    stocks = StockLocation.get_all_with_items_for_variants(variant_ids)

    line_items =
      Enum.reduce(order.line_items, %{}, fn %{variant_id: v_id} = li, acc ->
        Map.put(acc, v_id, li)
      end)

    stocks
    |> Stream.map(&package(&1, line_items))
    |> Stream.reject(fn x -> is_nil(x) end)
    # |> Stream.map(&attach_zone_info(order.shipping_address))
    |> Enum.map(&split_by_category/1)
    |> List.flatten()
  end

  defp package(stock_location, line_items) do
    items =
      stock_location.stock_items
      |> Stream.map(&make_item(&1, line_items))
      |> Enum.reject(fn x -> is_nil(x) end)

    if items == [],
      do: nil,
      else: %{
        items: items,
        shipping_methods: [],
        origin: struct(stock_location, stock_items: nil),
        category: nil,
        backorders?: nil
      }
  end

  defp make_item(%{variant: v} = stock_item, line_items) do
    li = line_items[v.id]
    state = item_state(stock_item, li)
    package_quantity = min(li.quantity, stock_item.count_on_hand)

    if is_nil(state),
      do: nil,
      else: %{
        variant_id: v.id,
        state: state,
        quantity: package_quantity,
        delta: li.quantity - package_quantity,
        line_item: li,
        variant: v
      }
  end

  defp item_state(stock_item, line_item) do
    if stock_item.count_on_hand >= line_item.quantity do
      :fulfilled
    else
      if stock_item.backorderable, do: :backordered, else: nil
    end
  end

  defp split_by_category(package) do
    package.items
    |> Stream.map(fn %{variant: v} -> Variant.get_category(v) end)
    |> Stream.zip(package.items)
    |> Enum.group_by(fn {%{id: c_id}, _} -> c_id end, fn {_, item} -> item end)
    |> Enum.reduce([], fn {c_id, items}, acc ->
      [
        %{
          items: items,
          category: %{id: c_id},
          origin: package.origin,
          shipping_methods: package.shipping_methods,
          backorders?: Enum.any?(items, fn %{state: state} -> state == :backordered end)
        }
        | acc
      ]
    end)
  end
end
