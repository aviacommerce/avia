defmodule Snitch.Domain.PackageItemTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase
  import Snitch.Factory

  alias Snitch.Domain.Inventory
  alias Snitch.Data.Model.StockItem

  describe "add_stock/2" do
    test "add stock successfully" do
      stock_location = insert(:stock_location)
      variant = insert(:variant)

      stock_query_map = %{product_id: variant.id, stock_location_id: stock_location.id}
      assert StockItem.get(stock_query_map) == nil

      stock_params = %{
        "product_id" => variant.id,
        "stock_location_id" => stock_location.id,
        "count_on_hand" => 15,
        "inventory_warning_level" => 3
      }

      {:ok, stock_item} = Inventory.add_stock(variant, stock_params)

      assert stock_item.count_on_hand == 15
      assert stock_item.inventory_warning_level == 3

      stock_params = %{
        "product_id" => variant.id,
        "stock_location_id" => stock_location.id,
        "count_on_hand" => 25
      }

      {:ok, stock_item} = Inventory.add_stock(variant, stock_params)

      assert stock_item.count_on_hand == 25
      assert stock_item.inventory_warning_level == 3
    end

    test "stock less then 0" do
      stock_location = insert(:stock_location)
      variant = insert(:variant)

      stock_params = %{
        "product_id" => variant.id,
        "stock_location_id" => stock_location.id,
        "count_on_hand" => -1
      }

      {:error, changeset} = Inventory.add_stock(variant, stock_params)

      refute changeset.valid?

      assert changeset.errors == [
               count_on_hand:
                 {"must be greater than %{number}", [validation: :number, number: -1]}
             ]
    end
  end

  describe "set_inventory_tracking/3" do
    test "set inventory tracking level as product" do
      category = insert(:taxon)
      stock_location = insert(:stock_location)
      product = insert(:product, taxon: category)

      stock_params = %{
        "product_id" => product.id,
        "stock_location_id" => stock_location.id,
        "count_on_hand" => 10
      }

      {:ok, product} =
        Inventory.set_inventory_tracking(product, :product, %{"stock" => stock_params})

      assert product.inventory_tracking == :product

      stock_query_map = %{product_id: product.id, stock_location_id: stock_location.id}
      stock_item = StockItem.get(stock_query_map)

      assert stock_item.count_on_hand == 10
      assert stock_item.inventory_warning_level == 0

      {:ok, product} = Inventory.set_inventory_tracking(product, :variant, %{})

      assert product.inventory_tracking == :variant

      {:ok, product} = Inventory.set_inventory_tracking(product, :none, %{})

      assert product.inventory_tracking == :none
    end

    test "set inventory tracking with invalid data" do
      category = insert(:taxon)
      stock_location = insert(:stock_location)
      product = insert(:product, taxon: category)

      {:error, changeset} = Inventory.set_inventory_tracking(product, :invalid_type, %{})

      refute changeset.valid?

      assert changeset.errors == [
               inventory_tracking:
                 {"is invalid", [type: InventoryTrackingEnum, validation: :cast]}
             ]

      stock_params = %{
        "product_id" => product.id,
        "stock_location_id" => stock_location.id,
        "count_on_hand" => -2
      }

      {:error, changeset} =
        Inventory.set_inventory_tracking(product, :product, %{"stock" => stock_params})

      refute changeset.valid?

      assert changeset.errors == [
               count_on_hand:
                 {"must be greater than %{number}", [validation: :number, number: -1]}
             ]
    end
  end
end
