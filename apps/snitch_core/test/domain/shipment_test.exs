defmodule Snitch.Domain.ShipmentTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase

  import Mox, only: [expect: 3, expect: 4, verify_on_exit!: 1]
  import Snitch.Factory
  import Snitch.Tools.Helper.{Order, Stock, Zone, Shipment}

  alias Snitch.Data.Schema.{Address, Order, Package, StockItem, StockLocation, Variant, Product}
  alias Snitch.Domain.Shipment

  @zone_manifest %{
    "domestic" => %{zone_type: "S"},
    "some_states" => %{zone_type: "S"}
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

  describe "default_packages/1" do
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
          country_id: india.id
        },
        "backup" => %{
          state_id: ka.id,
          country_id: india.id
        },
        "origin" => %{
          state_id: mh.id,
          country_id: india.id
        }
      }

      [stock_locations: stock_locations(manifest)]
    end

    setup :stock_items
    setup :verify_on_exit!

    @tag variant_count: 1, state_zone_count: 2
    test "force backorder package", context do
      %{
        variants: [%{id: one_id}] = vs,
        stock_locations: stock_locations,
        states: [ka, _, _, _, up, _],
        india: india,
        domestic: domestic,
        shipping_categories: [light, _, _]
      } = context

      # Line items:
      # + 4 pieces of variant_1
      #
      # default does not have enough, but is backorderable
      # backup  has none
      # origin  does not have enough
      address = %Address{state_id: up.id, country_id: india.id}
      line_items = line_items_with_price(vs, [4])
      order = %Order{id: 42, line_items: line_items, shipping_address: address}

      packages = Shipment.default_packages(order)

      assert length(packages) == 1

      {package, item} =
        packages
        |> Shipment.from(stock_locations["default"])
        |> find_item_by_variant_id(one_id)

      assert %{backorders?: true} = package
      assert length(package.items) == 1
      {state_zones, _} = package.zones
      assert length(state_zones) == 1
      assert package.origin.state_id == ka.id
      # origin is from a south indian state
      # assert that the zones is/are [domestic]
      assert Enum.find(state_zones, fn %{id: id} -> id == domestic.id end)

      assert package.category == light
      assert match_shipping_method_names(package, ~w(priority regular))

      assert %{
               delta: 1,
               quantity: 3,
               state: :backordered
             } = item
    end

    @tag variant_count: 2, state_zone_count: 2
    test "item out of stock so no package", context do
      %{
        variants: vs,
        states: [_, _, _, _, up, _],
        india: india
      } = context

      # Line items:
      # + 2 pieces of variant_2
      #
      # default has none
      # backup  has none
      # origin  has none
      address = %Address{state_id: up.id, country_id: india.id}
      line_items = line_items_with_price(vs, [0, 2])
      order = %Order{id: 42, line_items: line_items, shipping_address: address}

      assert [] = Shipment.default_packages(order)
    end

    @tag variant_count: 3, state_zone_count: 2
    test "fulfilled by default and backup", context do
      %{
        variants: [_, _, %{id: three_id}] = vs,
        stock_locations: stock_locations,
        states: [ka, _, tn, _, _, _],
        india: india,
        domestic: domestic,
        south_india: south_india,
        shipping_categories: [_, heavy, _]
      } = context

      # Line items:
      # + 6 pieces of variant_3
      #
      # default does not have enough, but is backorderable
      # backup  has enough
      # origin  does not have enough
      address = %Address{state_id: tn.id, country_id: india.id}
      line_items = line_items_with_price(vs, [0, 0, 6])
      order = %Order{id: 42, line_items: line_items, shipping_address: address}

      packages = Shipment.default_packages(order)

      assert length(packages) == 2

      {package, item} =
        packages
        |> Shipment.from(stock_locations["default"])
        |> find_item_by_variant_id(three_id)

      assert %{backorders?: true} = package
      assert length(package.items) == 1
      {state_zones, _} = package.zones
      assert length(state_zones) == 2
      # origin is from a south indian state
      assert package.origin.state_id == ka.id
      # assert zones is/are [domestic, south_india]
      assert Enum.find(state_zones, fn %{id: id} -> id == domestic.id end)
      assert Enum.find(state_zones, fn %{id: id} -> id == south_india.id end)

      assert package.category == heavy
      assert match_shipping_method_names(package, ~w(regular))

      assert %{
               delta: 3,
               quantity: 3,
               state: :backordered
             } = item

      {package, item} =
        packages
        |> Shipment.from(stock_locations["backup"])
        |> find_item_by_variant_id(three_id)

      assert %{backorders?: false} = package
      assert length(package.items) == 1
      {state_zones, _} = package.zones
      assert length(state_zones) == 2
      assert package.origin.state_id == ka.id
      # origin is from a south indian state
      # assert zones is/are [domestic, south_india]
      assert Enum.find(state_zones, fn %{id: id} -> id == domestic.id end)
      assert Enum.find(state_zones, fn %{id: id} -> id == south_india.id end)

      assert package.category == heavy
      assert match_shipping_method_names(package, ~w(regular))

      assert %{
               delta: 0,
               quantity: 6,
               state: :fulfilled
             } = item
    end

    @tag variant_count: 3, state_zone_count: 2
    test "package from default gets split (shipping_category)", context do
      %{
        variants: [%{id: one_id}, _, %{id: three_id}] = vs,
        stock_locations: stock_locations,
        states: [ka, _, _, _, _, mh],
        india: india,
        domestic: domestic,
        shipping_categories: [light, heavy, _]
      } = context

      # Line items:
      # + 4 pieces of variant_1
      # + 4 pieces of variant_3
      #
      # default does not have enough, but is backorderable (for both variants)
      # backup  has enough of variant_3, none of variant_1
      # origin  does not have enough
      address = %Address{state_id: mh.id, country_id: india.id}
      line_items = line_items_with_price(vs, [4, 0, 4])
      order = %Order{id: 42, line_items: line_items, shipping_address: address}

      packages = Shipment.default_packages(order)

      Enum.map(packages, fn %{items: items, category: c} ->
        assert Enum.all?(items, fn %{variant: v} ->
                 v.shipping_category_id == c.id
               end)
      end)

      assert length(packages) == 3

      {package, item} =
        packages
        |> Shipment.from(stock_locations["default"])
        |> find_item_by_variant_id(one_id)

      assert %{backorders?: true} = package
      assert length(package.items) == 1
      {state_zones, _} = package.zones
      assert length(state_zones) == 1
      assert package.origin.state_id == ka.id
      # origin is from a south indian state
      # assert zones is/are [domestic]
      assert Enum.find(state_zones, fn %{id: id} -> id == domestic.id end)

      assert package.category == light
      assert match_shipping_method_names(package, ~w(priority regular))

      assert %{
               delta: 1,
               quantity: 3,
               state: :backordered
             } = item

      {package, item} =
        packages
        |> Shipment.from(stock_locations["default"])
        |> find_item_by_variant_id(three_id)

      assert %{backorders?: true} = package
      assert length(package.items) == 1
      {state_zones, _} = package.zones
      assert length(state_zones) == 1
      assert package.origin.state_id == ka.id
      # origin is from a south indian state
      # assert zones is/are [domestic]
      assert Enum.find(state_zones, fn %{id: id} -> id == domestic.id end)

      assert package.category == heavy
      assert match_shipping_method_names(package, ~w(regular))

      assert %{
               delta: 1,
               quantity: 3,
               state: :backordered
             } = item

      {package, item} =
        packages
        |> Shipment.from(stock_locations["backup"])
        |> find_item_by_variant_id(three_id)

      assert %{backorders?: false} = package
      assert length(package.items) == 1
      {state_zones, _} = package.zones
      assert length(state_zones) == 1
      assert package.origin.state_id == ka.id
      # origin is from a south indian state
      # assert zones is/are [domestic]
      assert Enum.find(state_zones, fn %{id: id} -> id == domestic.id end)

      assert package.category == heavy
      assert match_shipping_method_names(package, ~w(regular))

      assert %{
               delta: 0,
               quantity: 4,
               state: :fulfilled
             } = item
    end

    @tag variant_count: 1, state_zone_count: 2
    test "zones", context do
      %{
        variants: [%{id: one_id}] = vs,
        stock_locations: stock_locations,
        states: [ka, _, _, _, _, mh],
        india: india,
        domestic: domestic,
        south_india: south_india,
        shipping_categories: [light, _, _]
      } = context

      # Line items:
      # + 3 pieces of variant_1
      #
      # default has enough
      # backup  has none
      # origin  has enough
      address = %Address{state_id: ka.id, country_id: india.id}
      line_items = line_items_with_price(vs, [3])
      order = %Order{id: 42, line_items: line_items, shipping_address: address}

      packages = Shipment.default_packages(order)

      assert length(packages) == 2

      {package, item} =
        packages
        |> Shipment.from(stock_locations["default"])
        |> find_item_by_variant_id(one_id)

      assert %{backorders?: false} = package
      assert length(package.items) == 1

      {state_zones, _} = package.zones
      assert length(state_zones) == 2
      assert package.origin.state_id == ka.id
      # origin is from a south indian state
      # assert zones is/are [domestic, south_india]
      assert Enum.find(state_zones, fn %{id: id} -> id == domestic.id end)
      assert Enum.find(state_zones, fn %{id: id} -> id == south_india.id end)

      assert package.category == light
      assert match_shipping_method_names(package, ~w(hyperloop priority regular))

      assert %{
               delta: 0,
               quantity: 3,
               state: :fulfilled
             } = item

      {package, item} =
        packages
        |> Shipment.from(stock_locations["origin"])
        |> find_item_by_variant_id(one_id)

      assert %{backorders?: false} = package
      assert length(package.items) == 1

      {state_zones, _} = package.zones
      assert length(state_zones) == 1
      assert package.origin.state_id == mh.id
      # origin is from a north indian state
      # assert zones is/are [domestic, south_india]
      assert Enum.find(state_zones, fn %{id: id} -> id == domestic.id end)

      assert package.category == light
      assert match_shipping_method_names(package, ~w(priority regular))

      assert %{
               delta: 0,
               quantity: 3,
               state: :fulfilled
             } = item
    end
  end

  describe "to_package/1" do
    setup :states

    setup %{states: states} do
      stock_item = insert(:stock_item, count_on_hand: 5)
      product = stock_item.product

      order = insert(:order, shipping_address: address_manifest(List.first(states)))

      tax_class_values = %{
        shipping_tax: %{class: insert(:tax_class), percent: 5},
        product_tax: %{class: product.tax_class, percent: 5}
      }

      setup_tax_with_zone_and_rates(tax_class_values, states)

      line_item = insert(:line_item, order: order, product: product, quantity: 2)

      [order: order, line_items: [line_item], variants: [product]]
    end

    setup :shipment!

    @tag state_count: 3
    test "embeds cost and shipping method together", context do
      %{
        order: order,
        line_items: [line_item],
        shipment: %{items: [shipment_item], shipping_methods: [shipping_method]} = shipment
      } = context

      assert %{
               items: [
                 %{
                   delta: 0,
                   quantity: 2,
                   backordered?: false,
                   state: "fulfilled"
                 } = item
               ],
               shipping_methods: [method],
               state: "pending"
             } = package = Shipment.to_package(shipment, order)

      assert item.line_item_id == shipment_item.line_item.id
      assert item.product_id == shipment_item.line_item.product_id
      assert item.tax
      assert package.shipping_category_id == shipment.category.id
      assert package.origin_id == shipment.origin.id
      assert package.order_id == order.id

      assert method.id == shipping_method.id
      assert method.cost == Money.zero(:USD)

      cs = Package.create_changeset(%Package{}, package)

      assert cs.valid?
      assert {:ok, _} = Repo.insert(cs)
    end
  end

  ################################################################################
  #                                                                              #
  #                                   HELPERS                                    #
  #                                                                              #
  ################################################################################

  defp find_item_by_variant_id(packages, variant_id) do
    Enum.reduce_while(packages, {nil, nil}, fn %{items: items, variants: vs} = p, _ ->
      if MapSet.member?(vs, variant_id) do
        {:halt,
         {
           p,
           Enum.find(items, fn %{variant: v} -> v.id == variant_id end)
         }}
      else
        {:cont, {nil, nil}}
      end
    end)
  end

  defp variants_with_categories(manifest, context) do
    {_, vs} = Repo.insert_all(Product, variants_with_manifest(manifest, context), returning: true)
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

  defp match_shipping_method_names(package, expected) do
    package.shipping_methods
    |> Enum.map(fn %{name: name} -> name end)
    |> MapSet.new()
    |> MapSet.equal?(MapSet.new(expected))
  end

  defp address_manifest(state) do
    %{
      first_name: "someone",
      last_name: "enoemos",
      address_line_1: "BR Ambedkar Chowk",
      address_line_2: "street",
      zip_code: "11111",
      city: "Rajendra Nagar",
      phone: "1234567890",
      country_id: state.country_id,
      state_id: state.id
    }
  end
end
