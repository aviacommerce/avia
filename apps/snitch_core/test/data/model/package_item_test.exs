defmodule Snitch.Data.Model.PackageItemTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase
  import Snitch.Factory
  alias Snitch.Data.Model.PackageItem

  setup do
    [order: insert(:order)]
  end

  setup :variants
  setup :line_items
  setup :shipping_categories
  setup :zones
  setup :shipping_methods

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
    test "fails with invalid params", context do
      %{line_items: [line_item]} = context

      assert {:error, changeset} =
               PackageItem.create(%{@params | line_item_id: -1, product_id: -1, package_id: -1})

      refute changeset.valid?
      assert %{package_id: ["does not exist"]} == errors_on(changeset)

      assert {:error, changeset} =
               PackageItem.create(%{
                 @params
                 | line_item_id: line_item.id,
                   product_id: -1,
                   package_id: -1
               })

      refute changeset.valid?
      assert %{package_id: ["does not exist"]} == errors_on(changeset)

      assert {:error, changeset} =
               PackageItem.create(%{
                 @params
                 | line_item_id: line_item.id,
                   product_id: line_item.product_id,
                   package_id: -1
               })

      refute changeset.valid?
      assert %{package_id: ["does not exist"]} == errors_on(changeset)
    end

    @tag variant_count: 1,
         shipping_category_count: 1,
         shipping_method_count: 1,
         state_zone_count: 1
    test "with valid params", context do
      %{line_items: [line_item]} = context

      assert {:ok, package_item} =
               PackageItem.create(%{
                 @params
                 | line_item_id: line_item.id,
                   product_id: line_item.product_id,
                   package_id: make_package(context).id
               })

      assert package_item.backordered?
    end
  end

  describe "update/2" do
    @tag variant_count: 1,
         shipping_category_count: 1,
         shipping_method_count: 1,
         state_zone_count: 1

    test "with valid params", context do
      %{line_items: [line_item]} = context

      assert {:ok, package_item} =
               PackageItem.create(%{
                 @params
                 | line_item_id: line_item.id,
                   product_id: line_item.product_id,
                   package_id: make_package(context).id
               })

      assert package_item.backordered?

      assert {:ok, package_item} =
               PackageItem.update(
                 %{
                   state: "destroyed",
                   quantity: 5,
                   delta: 0
                 },
                 package_item
               )

      refute package_item.backordered?
    end
  end

  defp make_package(context) do
    %{
      order: order,
      shipping_categories: [sc],
      shipping_methods: [sm]
    } = context

    insert(
      :package,
      order: order,
      shipping_category: sc,
      shipping_method_id: sm.id
    )
  end
end
