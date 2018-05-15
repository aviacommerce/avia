defmodule Snitch.Domain.ShipmentTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase

  import Snitch.{OrderCase, StockCase}
  import Snitch.Factory

  alias Snitch.Data.Schema.{StockItem, StockLocation, Order}
  alias Snitch.Domain.Shipment

  @sl_manifest %{
    "default" => %{
      default: true
    },
    "backup" => %{},
    "origin" => %{}
  }

  @si_manifest %{
    "default" => [
      %{count_on_hand: 3, backorderable: true},
      %{count_on_hand: 0},
      %{count_on_hand: 3, backorderable: true}
    ],
    "backup" => [
      %{count_on_hand: 0},
      %{count_on_hand: 0},
      %{count_on_hand: 6}
    ],
    "origin" => [
      %{count_on_hand: 3},
      %{count_on_hand: 0},
      %{count_on_hand: 3}
    ]
  }

  setup :variants
  setup :stock_locations
  setup :stock_items

  @tag variant_count: 1
  test "force backorder package", %{variants: vs} do
    # Line items:
    # + 4 pieces of variant_1
    #
    # default does not have enough, but is backorderable
    # backup  has none
    # origin  does not have enough

    line_items = line_items_with_price(vs, [4, 0, 0])
    order = %Order{id: 42, line_items: line_items}

    assert [
             %{
               backorders?: true,
               origin: %{admin_name: "default"},
               items: [
                 %{
                   quantity: 3,
                   delta: 1,
                   state: :backordered
                 }
               ]
             }
           ] = Shipment.default_packages(order)
  end

  @tag variant_count: 2
  test "item out of stock so no package", %{variants: vs} do
    # Line items:
    # + 2 pieces of variant_2
    #
    # default has none
    # backup  has none
    # origin  has none

    line_items = line_items_with_price(vs, [0, 2, 0])
    order = %Order{id: 42, line_items: line_items}

    assert [] = Shipment.default_packages(order)
  end

  @tag variant_count: 3
  test "fulfilled by default and backup", %{variants: vs} do
    # Line items:
    # + 6 pieces of variant_3
    #
    # default does not have enough, but is backorderable
    # backup  has enough
    # origin  does not have enough

    line_items = line_items_with_price(vs, [0, 0, 6])
    order = %Order{id: 42, line_items: line_items}

    assert %{
             "default" => %{
               backorders?: true,
               origin: %{admin_name: "default"},
               items: [
                 %{
                   delta: 3,
                   quantity: 3,
                   state: :backordered
                 }
               ]
             },
             "backup" => %{
               backorders?: false,
               origin: %{admin_name: "backup"},
               items: [
                 %{
                   delta: 0,
                   quantity: 6,
                   state: :fulfilled
                 }
               ]
             }
           } =
             order
             |> Shipment.default_packages()
             |> Enum.reduce(%{}, fn p, acc ->
               Map.put(acc, p.origin.admin_name, p)
             end)
  end

  @tag variant_count: 3
  test "foo", %{variants: vs} do
    # Line items:
    # + 4 pieces of variant_1
    # + 4 pieces of variant_3
    #
    # default does not have enough, but is backorderable (for both variants)
    # backup  has enough of variant_3, none of variant_1
    # origin  does not have enough

    [%{id: _one_id}, _, %{id: _three_id}] = vs
    line_items = line_items_with_price(vs, [4, 0, 4])
    order = %Order{id: 42, line_items: line_items}

    assert %{
             "default" => %{
               backorders?: true,
               origin: %{admin_name: "default"},
               items: [
                 %{
                   delta: 1,
                   quantity: 3,
                   state: :backordered,
                   variant_id: _one_id
                 },
                 %{
                   delta: 1,
                   quantity: 3,
                   state: :backordered,
                   variant_id: _three_id
                 }
               ]
             },
             "backup" => %{
               backorders?: false,
               origin: %{admin_name: "backup"},
               items: [
                 %{
                   delta: 0,
                   quantity: 4,
                   state: :fulfilled
                 }
               ]
             }
           } =
             order
             |> Shipment.default_packages()
             |> Enum.reduce(%{}, fn p, acc ->
               Map.put(acc, p.origin.admin_name, p)
             end)
  end

  # test "package has items of the same shipping category" do
  #   flunk("all items in your context are of same category, meh.")
  # end

  defp stock_locations(context) do
    locations =
      context
      |> Map.get(:stock_location_manifest, @sl_manifest)
      |> stock_locations_with_manifest()

    {_, stock_locations} = Repo.insert_all(StockLocation, locations, returning: true)

    [stock_locations: stock_locations]
  end

  defp stock_items(%{variants: vs, stock_locations: locations} = context) do
    stock_items =
      context
      |> Map.get(:stock_item_manifest, @si_manifest)
      |> stock_items_with_manifest(vs, locations)

    {_, stock_items} = Repo.insert_all(StockItem, stock_items, returning: true)

    [stock_items: stock_items]
  end
end
