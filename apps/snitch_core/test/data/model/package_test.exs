defmodule Snitch.Data.Model.PackageTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase

  import Snitch.Factory

  alias Snitch.Data.Model.Package
  alias Snitch.Data.Schema.ShippingMethod

  setup do
    [order: insert(:order)]
  end

  setup :variants
  setup :line_items
  setup :shipping_categories
  setup :zones

  @params %{
    number: "P01",
    state: "pending",
    shipping_methods: [],
    tracking: %{},
    order_id: 0,
    origin_id: 0,
    cost: Money.new(0, :USD),
    tax: Money.new(0, :USD),
    shipping_category_id: 0,
    shipping_method_id: nil
  }

  describe "create/1" do
    setup do
      [origin: insert(:stock_location)]
    end

    @tag variant_count: 1,
         shipping_category_count: 1,
         state_zone_count: 1
    test "with valid params", context do
      %{
        order: order,
        origin: origin,
        shipping_categories: [sc]
      } = context

      assert {:ok, package} =
               Package.create(%{
                 @params
                 | order_id: order.id,
                   origin_id: origin.id,
                   shipping_category_id: sc.id,
                   shipping_methods: [%ShippingMethod{}]
               })

      assert nil == package.shipping_method_id
    end

    @tag variant_count: 1,
         shipping_category_count: 1,
         state_zone_count: 1
    test "fails with missing assocs", context do
      %{
        order: order,
        origin: origin,
        shipping_categories: [sc]
      } = context

      params = %{@params | shipping_method_id: 0, shipping_methods: [%ShippingMethod{}]}
      assert {:error, cs} = Package.create(params)
      assert %{order_id: ["does not exist"]} == errors_on(cs)

      params = %{params | order_id: order.id}
      assert {:error, cs} = Package.create(params)
      assert %{origin_id: ["does not exist"]} == errors_on(cs)

      params = %{params | origin_id: origin.id}
      assert {:error, cs} = Package.create(params)
      assert %{shipping_category_id: ["does not exist"]} == errors_on(cs)

      params = %{params | shipping_category_id: sc.id}
      assert {:error, cs} = Package.create(params)
      assert %{shipping_method_id: ["does not exist"]} == errors_on(cs)

      params = %{params | shipping_methods: []}
      assert {:error, cs} = Package.create(params)
      assert %{shipping_methods: ["can't be blank"]} == errors_on(cs)
    end
  end

  describe "update/1" do
    setup %{
      order: order,
      shipping_categories: [sc]
    } do
      origin = insert(:stock_location)

      {:ok, package} =
        Package.create(%{
          @params
          | order_id: order.id,
            origin_id: origin.id,
            shipping_category_id: sc.id,
            shipping_methods: [%ShippingMethod{}]
        })

      [package: package, origin: insert(:stock_location)]
    end

    setup :shipping_methods

    @tag variant_count: 1,
         shipping_category_count: 1,
         shipping_method_count: 1,
         state_zone_count: 1
    test "with valid params", %{package: package} = context do
      %{shipping_methods: [sm]} = context

      assert [_] = package.shipping_methods

      params = %{
        shipping_method_id: sm.id
      }

      {:ok, updated_package} = Package.update(package, params)

      {:ok, _} = Package.update(updated_package, %{shipping_methods: []})
    end
  end
end
