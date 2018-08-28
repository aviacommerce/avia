defmodule Snitch.Domain.ShipmentEngineTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase

  import Snitch.Factory
  import Snitch.ShipmentEngineCase
  import Snitch.Tools.Helper.Order

  alias Snitch.Data.Schema.Order
  alias Snitch.Domain.ShipmentEngine

  setup :variants

  describe "order fulfilled" do
    @tag variant_count: 4
    test "with multiple packages", context do
      package_manifest = [[1, 0, 1, 0], [1, 1, 1, 1], [1, 0, 0, 0], [0, 1, 0, 1]]
      %{variants: vs} = context
      line_items = line_items_with_price(vs, [1, 1, 1, 1])
      order = %Order{id: 42, line_items: line_items, shipping_address: insert(:address)}
      packages = packages(line_items, context, package_manifest)
      value = ShipmentEngine.run(packages, order)

      line_items_set =
        Enum.reduce(line_items, MapSet.new(), fn item, acc ->
          MapSet.put(acc, item.product_id)
        end)

      package_items_set = fulfilled_items(value)
      assert MapSet.equal?(line_items_set, package_items_set)
    end

    @tag variant_count: 4
    test "with single package", context do
      package_manifest = [[1, 1, 1, 1]]
      %{variants: vs} = context
      line_items = line_items_with_price(vs, [1, 1, 1, 1])
      order = %Order{id: 42, line_items: line_items, shipping_address: insert(:address)}
      packages = packages(line_items, context, package_manifest)
      value = ShipmentEngine.run(packages, order)

      line_items_set =
        Enum.reduce(line_items, MapSet.new(), fn item, acc ->
          MapSet.put(acc, item.product_id)
        end)

      package_items_set = fulfilled_items(value)
      assert MapSet.equal?(line_items_set, package_items_set)
    end
  end

  describe "order unfulfilled" do
    @tag variant_count: 4
    test "with multiple packages", context do
      package_manifest = [[1, 0, 1, 0], [1, 1, 1, 0], [1, 0, 0, 0], [0, 1, 0, 0]]
      %{variants: vs} = context
      line_items = line_items_with_price(vs, [1, 1, 1, 1])
      order = %Order{id: 42, line_items: line_items, shipping_address: insert(:address)}
      packages = packages(line_items, context, package_manifest)
      assert [] = ShipmentEngine.run(packages, order)
    end

    @tag variant_count: 4
    test "with single package", context do
      package_manifest = [[1, 1, 1, 0]]
      %{variants: vs} = context
      line_items = line_items_with_price(vs, [1, 1, 1, 1])
      order = %Order{id: 42, line_items: line_items, shipping_address: insert(:address)}
      packages = packages(line_items, context, package_manifest)
      assert [] = ShipmentEngine.run(packages, order)
    end
  end

  defp fulfilled_items(pckgs) do
    Enum.reduce(pckgs, MapSet.new(), fn %{variants: vs}, acc ->
      MapSet.union(acc, vs)
    end)
  end
end
