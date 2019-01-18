defmodule Snitch.Data.Model.StockItemTest do
  @moduledoc false

  use ExUnit.Case, async: true
  use Snitch.DataCase
  import Snitch.Factory
  alias Snitch.Data.Model.StockItem, as: StockItemModel

  describe "create/4" do
    test "Fails for INVALID attributes" do
      assert {:error, changeset} = StockItemModel.create(-1, -1, 1, true)
      refute changeset.valid?
      assert %{stock_location_id: ["does not exist"]} = errors_on(changeset)
    end

    test "Fails with ONLY valid Stock Location" do
      stock_location = insert(:stock_location)
      assert {:error, changeset} = StockItemModel.create(-1, stock_location.id, 1, true)
      refute changeset.valid?
      assert %{product_id: ["does not exist"]} = errors_on(changeset)
    end

    test "Fails with ONLY Stock Location, Variant" do
      stock_location = insert(:stock_location)
      variant = insert(:variant)

      assert {:error, changeset} = StockItemModel.create(variant.id, stock_location.id, -1, true)
      assert %{count_on_hand: ["must be greater than -1"]} = errors_on(changeset)
    end

    test "Inserts with valid attributes" do
      stock_location = insert(:stock_location)
      variant = insert(:variant)

      assert {:ok, _stock_item} = StockItemModel.create(variant.id, stock_location.id, 1, true)
    end
  end

  describe "get/1" do
    test "Fails with invalid id" do
      stock_item = StockItemModel.get(-1)
      assert {:error, :stock_item_not_found} == stock_item
    end

    test "gets with valid id" do
      insert_stock_item = insert(:stock_item)

      {:ok, get_stock_item} = StockItemModel.get(insert_stock_item.id)
      assert insert_stock_item.id == get_stock_item.id
      assert insert_stock_item.stock_location_id == get_stock_item.stock_location_id
      assert insert_stock_item.product_id == get_stock_item.product_id
      assert insert_stock_item.count_on_hand == get_stock_item.count_on_hand

      # with stock item map
      {:ok, get_stock_item_with_map} = StockItemModel.get(%{id: insert_stock_item.id})
      assert insert_stock_item.id == get_stock_item_with_map.id
      assert insert_stock_item.stock_location_id == get_stock_item_with_map.stock_location_id
      assert insert_stock_item.product_id == get_stock_item_with_map.product_id
      assert insert_stock_item.count_on_hand == get_stock_item_with_map.count_on_hand
    end
  end

  describe "update/2" do
    test "without stock instance : Fails for INVALID attributes" do
      stock_item = insert(:stock_item)

      assert {:error, changeset} = StockItemModel.update(%{count_on_hand: -2, id: stock_item.id})
      assert %{count_on_hand: ["must be greater than -1"]} = errors_on(changeset)
    end

    test "without stock instance : updates for VALID attributes" do
      stock_item = insert(:stock_item)

      assert {:ok, updated_stock_item} =
               StockItemModel.update(%{count_on_hand: 20, id: stock_item.id})

      assert stock_item.count_on_hand != updated_stock_item.count_on_hand
      assert updated_stock_item.count_on_hand == 20
    end

    test "with stock instance : Fails for INVALID attributes" do
      stock_item = insert(:stock_item)
      assert {:error, changeset} = StockItemModel.update(%{count_on_hand: -2}, stock_item)
      assert %{count_on_hand: ["must be greater than -1"]} = errors_on(changeset)
    end

    test "with stock instance : updates for VALID attributes" do
      stock_item = insert(:stock_item)

      assert {:ok, updated_stock_item} = StockItemModel.update(%{count_on_hand: 20}, stock_item)

      assert stock_item.count_on_hand != updated_stock_item.count_on_hand
      assert updated_stock_item.count_on_hand == 20
    end
  end

  describe "delete/1" do
    test "Fails to delete if invalid id" do
      assert {:error, :not_found} = StockItemModel.delete(-1)
    end

    test "Deletes for valid id" do
      stock_item = insert(:stock_item)
      assert {:ok, _} = StockItemModel.delete(stock_item.id)
    end

    test "Deletes for valid stock item" do
      stock_item = insert(:stock_item)
      assert {:ok, _} = StockItemModel.delete(stock_item)
    end
  end

  describe "get_all/0" do
    test "fetches all the stock items" do
      stock_items = StockItemModel.get_all()
      assert 0 = Enum.count(stock_items)

      # add for multiple random variants
      insert_list(1, :stock_item)
      insert_list(2, :stock_item)

      stock_items_new = StockItemModel.get_all()
      assert 3 = Enum.count(stock_items_new)
    end
  end

  describe "with_active_stock_location/1" do
    test "returns empty list for invalid variant id" do
      stock_items = StockItemModel.with_active_stock_location(-1)
      assert Enum.count(stock_items) == 0
    end

    test "fetch all stock items for a valid variant" do
      variant1 = insert(:variant)
      variant2 = insert(:variant)
      variant3 = insert(:variant)

      insert_list(2, :stock_item, product: variant1)
      assert Enum.count(StockItemModel.with_active_stock_location(variant1.id)) == 2

      insert_list(5, :stock_item, product: variant2)
      assert Enum.count(StockItemModel.with_active_stock_location(variant2.id)) == 5

      # Test for inactive stock locationlocation
      inactive_stock_location = insert(:stock_location, active: false)
      insert(:stock_item, product: variant3, stock_location: inactive_stock_location)
      insert_list(2, :stock_item, product: variant3)
      assert Enum.count(StockItemModel.with_active_stock_location(variant3.id)) == 2
    end
  end

  describe "total_on_hand/1" do
    test "return nil for invalid variant id" do
      assert 0 == StockItemModel.total_on_hand(-1)
    end

    test "return total count on hand in all stock items for a variant at active locations" do
      variant = insert(:variant)
      inactive_stock_location = insert(:stock_location, active: false)
      insert(:stock_item, product: variant, stock_location: inactive_stock_location)
      stock_items = insert_list(3, :stock_item, product: variant)

      total_count_on_hand =
        stock_items
        |> Stream.map(& &1.count_on_hand)
        |> Enum.reduce(0, &Kernel.+/2)

      assert total_count_on_hand == StockItemModel.total_on_hand(variant.id)
    end
  end

  describe "get_stock/2" do
    test "return stock successfully" do
      variant = insert(:variant)
      active_stock_location = insert(:stock_location, active: true)
      insert(:stock_item, product: variant, stock_location: active_stock_location)
      stock_items = insert_list(3, :stock_item, product: variant)

      stock = StockItemModel.get_stock(variant.id, active_stock_location.id)
      assert length(stock) == 1
    end

    test "no stock for product" do
      variant = insert(:variant)
      active_stock_location = insert(:stock_location, active: true)

      assert StockItemModel.get_stock(variant.id, active_stock_location.id) == []
    end
  end
end
