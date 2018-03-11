defmodule Snitch.Data.Model.StockItemTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase
  import Snitch.Factory
  alias Snitch.Data.Model

  describe "create/4" do
    test "Fails for INVALID attributes" do
      assert {:error, changeset} = Model.StockItem.create(1, 1, 1, true)
      refute changeset.valid?
      assert %{stock_location_id: ["does not exist"]} = errors_on(changeset)
    end

    test "Fails with ONLY valid Stock Location" do
      stock_location = insert(:stock_location)
      assert {:error, changeset} = Model.StockItem.create(1, stock_location.id, 1, true)
      refute changeset.valid?
      assert %{variant_id: ["does not exist"]} = errors_on(changeset)
    end

    test "Fails with ONLY Stock Location, Variant" do
      stock_location = insert(:stock_location)
      variant = insert(:variant)

      assert {:error, changeset} = Model.StockItem.create(variant.id, stock_location.id, -1, true)

      assert [
               count_on_hand: {
                 "must be greater than %{number}",
                 [validation: :number, number: -1]
               }
             ] = changeset
    end

    test "Inserts with valid attributes" do
      stock_location = insert(:stock_location)
      variant = insert(:variant)

      assert {:ok, stock_item} = Model.StockItem.create(variant.id, stock_location.id, 1, true)
    end
  end

  describe "get/1" do
    test "Fails with invalid id" do
      stock_item = Model.StockItem.get(1)
      assert nil == stock_item
    end

    test "gets with valid id" do
      insert_stock_item = insert(:stock_item)

      get_stock_item = Model.StockItem.get(insert_stock_item.id)
      assert insert_stock_item.id == get_stock_item.id
      assert insert_stock_item.stock_location_id == get_stock_item.stock_location_id
      assert insert_stock_item.variant_id == get_stock_item.variant_id
      assert insert_stock_item.count_on_hand == get_stock_item.count_on_hand

      # with stock item map
      get_stock_item_with_map = Model.StockItem.get(%{id: insert_stock_item.id})
      assert insert_stock_item.id == get_stock_item_with_map.id
      assert insert_stock_item.stock_location_id == get_stock_item_with_map.stock_location_id
      assert insert_stock_item.variant_id == get_stock_item_with_map.variant_id
      assert insert_stock_item.count_on_hand == get_stock_item_with_map.count_on_hand
    end
  end

  describe "update/2" do
    test "without stock instance : Fails for INVALID attributes" do
      stock_item = insert(:stock_item)

      assert {:error, changeset} = Model.StockItem.update(%{count_on_hand: -1, id: stock_item.id})

      assert [
               count_on_hand: {
                 "must be greater than %{number}",
                 [validation: :number, number: -1]
               }
             ] = changeset
    end

    test "without stock instance : updates for VALID attributes" do
      stock_item = insert(:stock_item)

      assert {:ok, updated_stock_item} =
               Model.StockItem.update(%{count_on_hand: 20, id: stock_item.id})

      assert stock_item.count_on_hand != updated_stock_item.count_on_hand
      assert 20 = updated_stock_item.count_on_hand
    end

    test "with stock instance : Fails for INVALID attributes" do
      stock_item = insert(:stock_item)
      assert {:error, changeset} = Model.StockItem.update(%{count_on_hand: -1}, stock_item)

      assert [
               count_on_hand: {
                 "must be greater than %{number}",
                 [validation: :number, number: -1]
               }
             ] = changeset
    end

    test "with stock instance : updates for VALID attributes" do
      stock_item = insert(:stock_item)

      assert {:ok, updated_stock_item} = Model.StockItem.update(%{count_on_hand: 20}, stock_item)

      assert stock_item.count_on_hand != updated_stock_item.count_on_hand
      assert 20 = updated_stock_item.count_on_hand
    end
  end

  describe "delete/1" do
    test "Fails to delete if invalid id" do
      assert {:error, :not_found} = Model.StockItem.delete(1_234_567_890)
    end

    test "Deletes for valid id" do
      stock_item = insert(:stock_item)
      assert stock_item = Model.StockItem.delete(stock_item.id)
    end

    test "Deletes for valid stock item" do
      stock_item = insert(:stock_item)
      assert stock_item = Model.StockItem.delete(stock_item)
    end
  end

  describe "get_all/0" do
    test "fetches all the stock items" do
      stock_items = Model.StockItem.get_all()
      assert 0 = Enum.count(stock_items)

      # add for multiple random variants
      insert_list(1, :stock_item)
      insert_list(2, :stock_item)

      stock_items_new = Model.StockItem.get_all()
      assert 3 = Enum.count(stock_items_new)
    end
  end

  describe "with_active_stock_location/1" do
    test "returns empty list for invalid variant id" do
      stock_items = Model.StockItem.with_active_stock_location(1_234_567_890)
      assert 0 = Enum.count(stock_items)
    end

    test "fetch all stock items for a valid variant" do
      variant1 = insert(:variant)
      variant2 = insert(:variant)
      variant3 = insert(:variant)

      insert_list(2, :stock_item, variant: variant1)
      assert 2 = Enum.count(Model.StockItem.with_active_stock_location(variant1.id))

      insert_list(5, :stock_item, variant: variant2)
      assert 5 = Enum.count(Model.StockItem.with_active_stock_location(variant2.id))

      # Test for inactive stock locationlocation
      inactive_stock_location = insert(:stock_location, active: false)
      insert(:stock_item, variant: variant3, stock_location: inactive_stock_location)
      insert_list(2, :stock_item, variant: variant3)
      assert 2 = Enum.count(Model.StockItem.with_active_stock_location(variant3.id))
    end
  end

  describe "total_on_hand/1" do
    test "return nil for invalid variant id" do
      assert nil == Model.StockItem.total_on_hand(1_234_567_890)
    end

    test "return total count on hand in all stock items for a variant at active locations" do
      variant = insert(:variant)
      inactive_stock_location = insert(:stock_location, active: false)
      insert(:stock_item, variant: variant, stock_location: inactive_stock_location)
      stock_items = insert_list(3, :stock_item, variant: variant)

      total_count_on_hand =
        stock_items
        |> Enum.map(& &1.count_on_hand)
        |> Enum.reduce(0, &Kernel.+/2)

      assert total_count_on_hand == Model.StockItem.total_on_hand(variant.id)
    end
  end
end
