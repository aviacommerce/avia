defmodule Snitch.Domain.Splitter.WeightTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase

  # TODO: Build the packages by hand, possibly using `Factory.Shipping.shipment!`
  # not using `Shipment.default_packages/1`
  import Mox, only: [expect: 4, verify_on_exit!: 1]
  import Snitch.Tools.Helper.{Order, Shipment, Stock, Zone}

  alias Snitch.Data.Schema.{Address, Order, StockItem, StockLocation, Product}
  alias Snitch.Domain.Shipment
  alias Snitch.Domain.Splitters.Weight, as: WeightSplitter

  @zone_manifest %{
    "domestic" => %{zone_type: "S"},
    "some_states" => %{zone_type: "S"}
  }

  @si_manifest %{
    "default" => [
      %{count_on_hand: 3, backorderable: true},
      %{count_on_hand: 2, backorderable: true},
      %{count_on_hand: 3, backorderable: true}
    ],
    "backup" => [
      %{count_on_hand: 0},
      %{count_on_hand: 0},
      %{count_on_hand: 6}
    ],
    "origin" => [
      %{count_on_hand: 3},
      %{count_on_hand: 3},
      %{count_on_hand: 3}
    ]
  }

  setup context do
    [india] = countries_with_manifest(~w(IN))

    [ka, ap, tn, kl, _up, _mh] =
      states =
      states_with_manifest([
        {"KA", "IN-KA", india},
        {"AP", "IN-AP", india},
        {"TN", "IN-TN", india},
        {"KL", "IN-KL", india},
        {"UP", "IN-UP", india},
        {"MH", "IN-MH", india}
      ])

    zones = [domestic, south_india] = zones_with_manifest(@zone_manifest)

    zone_members([
      {domestic, states},
      {south_india, [ka, ap, tn, kl]}
    ])

    categories =
      [light, heavy, fragile] = shipping_categories_with_manifest(~w(light heavy fragile))

    shipping_method_manifest = %{
      "priority" => {zones, [light, fragile]},
      "regular" => {zones, categories},
      "hyperloop" => {[south_india], [light]}
    }

    methods = shipping_methods_with_manifest(shipping_method_manifest)

    variant_manifest = [
      %{category: light},
      %{category: fragile},
      %{category: heavy}
    ]

    vs = variants_with_categories(variant_manifest, context)

    [
      india: india,
      states: states,
      zones: zones,
      domestic: domestic,
      south_india: south_india,
      zones: zones,
      shipping_categories: categories,
      shipping_methods: methods,
      variants: vs
    ]
  end

  setup context do
    %{states: [ka, _, _, _, _, mh], india: india} = context

    manifest = %{
      "default" => %{
        default: true,
        state_id: ka.id,
        country_id: india.id,
        name: "default"
      },
      "backup" => %{
        state_id: ka.id,
        country_id: india.id,
        name: "default"
      },
      "origin" => %{
        state_id: mh.id,
        country_id: india.id,
        name: "default"
      }
    }

    [stock_locations: stock_locations(manifest)]
  end

  setup :stock_items
  setup :verify_on_exit!

  describe "split/1" do
    # Default Packages
    #
    # | Package | Item/Variant | Weight | Δ | Quantity |
    # |---------|--------------|--------|---|----------|
    # | 1       | 1            | 10     | 0 | 1        |
    # | 2       | 1            | 10     | 0 | 1        |

    # After Weight Splitting
    #
    # | Package | Item/Variant | Weight | Δ | Quantity |
    # |---------|--------------|--------|---|----------|
    # | 1       | 1            | 10     | 0 | 1        |
    # | 2       | 1            | 10     | 0 | 1        |

    @tag weights: [10.0], variant_count: 1, state_zone_count: 2
    test "no package with weight over threshold", context do
      %{
        variants: vs,
        states: [_, _, _, _, up, _],
        india: india
      } = context

      address = %Address{state_id: up.id, country_id: india.id}
      line_items = line_items_with_price(vs, [1])
      order = %Order{id: 42, line_items: line_items, shipping_address: address}

      packages =
        order
        |> Shipment.default_packages()
        |> WeightSplitter.split()

      # Item {delta, quantity}
      packages_to_assert = [
        [{0, 1}],
        [{0, 1}]
      ]

      assert length(packages) == 2

      packages
      |> Enum.zip(packages_to_assert)
      |> Enum.map(&assert_package/1)
    end
  end

  # Default packages
  #
  # | Package | Item/Variant | Weight | Δ | Quantity |
  # |---------|--------------|--------|---|----------|
  # | 1       | 1            | 30     | 1 | 2        |
  # | 2       | 2            | 60     | 0 | 3        |
  # | 3       | 1            | 30     | 0 | 3        |
  # | 4       | 2            | 60     | 0 | 3        |

  # After weight splitting
  #
  # | Parent Package | Package | Item/Variant | Weight | Δ | Quantity |
  # +================+=========+==============+========+===+==========+
  # | 1              | 1       | 1            | 90     | 1 | 2        |
  # +----------------+---------+--------------+--------+---+----------+
  # | 2              | 2       | 2            | 60     | 0 | 1        |
  # |                +---------+--------------+--------+---+----------+
  # |                | 3       | 2            | 120    | 0 | 2        |
  # +----------------+---------+--------------+--------+---+----------+
  # | 3              | 4       | 1            | 90     | 0 | 3        |
  # +----------------+---------+--------------+--------+---+----------+
  # | 4              | 5       | 2            | 60     | 0 | 1        |
  # |                +---------+--------------+--------+---+----------+
  # |                | 6       | 2            | 120    | 0 | 2        |

  @tag weights: [60.0, 30.0], variant_count: 2, state_zone_count: 2
  test "split package with more cumulative weight", context do
    %{
      variants: vs,
      states: [_ka, _, _, _, up, _],
      india: india
    } = context

    address = %Address{state_id: up.id, country_id: india.id}
    line_items = line_items_with_price(vs, [3, 3])
    order = %Order{id: 42, line_items: line_items, shipping_address: address}

    packages =
      order
      |> Shipment.default_packages()
      |> WeightSplitter.split()

    # Item {delta, quantity}
    packages_to_assert = [
      [{1, 2}],
      [{0, 1}],
      [{0, 2}],
      [{0, 3}],
      [{0, 1}],
      [{0, 2}]
    ]

    assert length(packages) == 6

    packages
    |> Enum.zip(packages_to_assert)
    |> Enum.map(&assert_package/1)
  end

  # Default packages
  #
  # | Package | Item/Variant | Weight | Δ | Quantity |
  # |---------|--------------|--------|---|----------|
  # | 1       | 2            | 40     | 4 | 2        |
  # | 2       | 1            | 10     | 0 | 2        |
  # | 3       | 1            | 10     | 0 | 2        |

  # After weight splitting
  #
  # | Parent Package | Package | Item/Variant | Weight | Δ | Quantity |
  # +================+=========+==============+========+===+==========+
  # | 1              | 1       | 2            | 120    | 3 | 0        |
  # |                +---------+--------------+--------+---+----------+
  # |                | 2       | 2            | 120    | 1 | 2        |
  # +----------------+---------+--------------+--------+---+----------+
  # | 2              | 3       | 1            | 20     | 0 | 2        |
  # +----------------+---------+--------------+--------+---+----------+
  # | 3              | 4       | 1            | 20     | 0 | 2        |

  @tag weights: [10.0, 40.0], variant_count: 2, state_zone_count: 2
  test "split package with uneven weight", context do
    %{
      variants: vs,
      states: [_, _, _, _, up, _],
      india: india
    } = context

    address = %Address{state_id: up.id, country_id: india.id}
    line_items = line_items_with_price(vs, [2, 6])
    order = %Order{id: 42, line_items: line_items, shipping_address: address}

    packages =
      order
      |> Shipment.default_packages()
      |> WeightSplitter.split()

    # Item {delta, quantity}
    packages_to_assert = [
      [{3, 0}],
      [{1, 2}],
      [{0, 2}],
      [{0, 2}]
    ]

    assert length(packages) == 4

    packages
    |> Enum.zip(packages_to_assert)
    |> Enum.map(&assert_package/1)
  end

  defp assert_package({package, items_to_assert}) do
    package.items
    |> Enum.zip(items_to_assert)
    |> Enum.map(&assert_item/1)
  end

  defp assert_item({item, {delta, quantity}}) do
    assert item.delta == delta
    assert item.quantity == quantity
  end

  def pretty_print_package(package) do
    %{
      items:
        Enum.map(package.items, fn item ->
          %{weight: item.variant.weight, quantity: item.quantity, delta: item.delta}
        end)
    }
  end

  defp variants_with_categories(manifest, context) do
    variants =
      manifest
      |> variants_with_manifest(context)
      |> Enum.zip(context.weights)
      |> Enum.map(fn {variant, weight} -> %{variant | weight: Decimal.new(weight)} end)

    {_, vs} = Repo.insert_all(Product, variants, returning: true)
    vs
  end

  defp stock_locations(manifest) do
    locations = stock_locations_with_manifest(manifest)

    {_, stock_locations} = Repo.insert_all(StockLocation, locations, returning: true)

    Enum.reduce(stock_locations, %{}, fn sl, acc ->
      Map.put(acc, sl.name, sl)
    end)
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
