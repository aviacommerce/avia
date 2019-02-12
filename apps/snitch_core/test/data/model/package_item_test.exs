defmodule Snitch.Data.Model.PackageItemTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase

  import Snitch.Factory

  alias Snitch.Data.Model.PackageItem

  setup :variants
  setup :shipping_categories
  setup :zones
  setup :shipping_methods
  setup :embedded_shipping_methods

  @params %{
    number: "PI01",
    state: "ready",
    quantity: 3,
    delta: 2,
    backordered?: true,
    product_id: nil,
    line_item_id: nil,
    package_id: nil,
    tax: Money.zero(:INR)
  }

  describe "create/1" do
    @tag variant_count: 1,
         shipping_category_count: 1,
         shipping_method_count: 1,
         state_zone_count: 1
    test "successful with valid params", context do
      %{line_item: line_item, package: package, product: product} = new_package(context)

      assert {:ok, _} =
               PackageItem.create(%{
                 @params
                 | line_item_id: line_item.id,
                   product_id: product.id,
                   package_id: package.id
               })
    end

    test "failed for invalid params" do
      {:error, cs} =
        PackageItem.create(%{
          @params
          | line_item_id: 2,
            product_id: 3,
            package_id: -2
        })

      assert %{package_id: ["does not exist"]} == errors_on(cs)
    end
  end

  describe "update/2" do
    @tag variant_count: 1,
         shipping_category_count: 1,
         shipping_method_count: 1,
         state_zone_count: 1
    test "successful with valid params", context do
      %{package_item: package_item} = make_package_item(context)
      params = %{quantity: 95}
      {:ok, updated_package_item} = PackageItem.update(params, package_item)
      assert updated_package_item.id == package_item.id
      assert updated_package_item.quantity != package_item.quantity
      refute updated_package_item.backordered?
    end

    test "failed for invalid params", context do
      %{package_item: package_item} = make_package_item(context)
      money = Money.new(-1, :USD)
      updates = %{tax: money}
      {:error, updated} = PackageItem.update(updates, package_item)
      assert %{tax: ["must be equal or greater than 0"]} == errors_on(updated)
    end
  end

  describe "delete/1" do
    test "a package_item", context do
      %{package_item: package_item} = make_package_item(context)
      {:ok, _} = PackageItem.delete(package_item)
      assert {:error, :package_item_not_found} == PackageItem.get(package_item.id)
    end
  end

  describe "get/1" do
    test "with non-negative integer", context do
      %{package_item: package_item} = make_package_item(context)
      {:ok, new_package_item} = PackageItem.get(package_item.id)
      assert new_package_item.id == package_item.id
    end

    test "with a map", context do
      %{package_item: package_item} = make_package_item(context)
      map = %{number: package_item.number}
      {:ok, new_package_item} = PackageItem.get(map)
      assert new_package_item.id == package_item.id
    end
  end

  describe "get_all/0" do
    test "package_items", context do
      %{package_item: _package_item} = make_package_item(context)
      assert PackageItem.get_all() != []
    end
  end

  defp new_package(context) do
    %{embedded_shipping_methods: embedded_shipping_methods} = context

    country = insert(:country)
    state = insert(:state, country: country)
    stock_location = insert(:stock_location, state: state)
    stock_item = insert(:stock_item, count_on_hand: 10, stock_location: stock_location)
    shipping_category = insert(:shipping_category)
    product = stock_item.product
    order = insert(:order, state: "delivery")
    line_item = insert(:line_item, order: order, product: product, quantity: 3)

    package =
      insert(:package,
        shipping_methods: embedded_shipping_methods,
        order: order,
        items: [],
        origin: stock_item.stock_location,
        shipping_category: shipping_category
      )

    %{line_item: line_item, package: package, product: product}
  end

  defp make_package_item(context) do
    %{line_item: line_item, package: package, product: product} = new_package(context)

    package_item =
      insert(:package_item,
        quantity: 3,
        product: product,
        line_item: line_item,
        package: package
      )

    %{package_item: package_item}
  end
end
