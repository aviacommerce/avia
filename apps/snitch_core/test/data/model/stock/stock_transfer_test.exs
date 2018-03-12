defmodule Snitch.Data.Model.StockTransferTest do
  @moduledoc false

  use ExUnit.Case, async: true
  use Snitch.DataCase
  import Snitch.Factory
  alias Snitch.Data.Model.StockTransfer, as: StockTransferModel

  setup do
    [stock_location: insert(:stock_location)]
  end

  describe "create/4" do
    test "Fails for INVALID number id" do
      assert {:error, changeset} = StockTransferModel.create("", "", -1, -1)
      refute changeset.valid?
      assert %{number: ["can't be blank"]} = errors_on(changeset)
    end

    test "Fails with invalid destinaton location" do
      assert {:error, changeset} = StockTransferModel.create("", "T2132", nil, nil)
      refute changeset.valid?
      assert %{destination_location_id: ["can't be blank"]} = errors_on(changeset)
    end

    test "Inserts with valid attributes", context do
      %{stock_location: stock_location} = context

      assert {:ok, stock_transfer} =
               StockTransferModel.create("", "T1235450", nil, stock_location.id)

      assert stock_transfer.destination_location_id == stock_location.id
    end
  end

  describe "get/1" do
    test "Fails with invalid id" do
      stock_item = StockTransferModel.get(1)
      assert nil == stock_item
    end

    test "gets with valid id", context do
      %{stock_location: stock_location} = context
      insert_stock_transfer = insert(:stock_transfer, destination_location: stock_location)

      get_stock_transfer = StockTransferModel.get(insert_stock_transfer.id)
      assert insert_stock_transfer.id == get_stock_transfer.id
      assert insert_stock_transfer.destination_location_id == stock_location.id
      assert insert_stock_transfer.number == get_stock_transfer.number
      assert insert_stock_transfer.reference == get_stock_transfer.reference
      assert insert_stock_transfer.source_location_id == get_stock_transfer.source_location_id

      # with stock item map
      get_stock_transfer_with_map = StockTransferModel.get(%{id: insert_stock_transfer.id})
      assert insert_stock_transfer.id == get_stock_transfer_with_map.id
      assert insert_stock_transfer.destination_location_id == stock_location.id
      assert insert_stock_transfer.number == get_stock_transfer_with_map.number
      assert insert_stock_transfer.reference == get_stock_transfer_with_map.reference

      assert insert_stock_transfer.source_location_id ==
               get_stock_transfer_with_map.source_location_id
    end
  end

  describe "get_all/0" do
    test "fetches all the stock items" do
      stock_transfers = StockTransferModel.get_all()
      assert [] = stock_transfers

      # add for multiple random stock items
      insert_list(1, :stock_transfer)
      insert_list(2, :stock_transfer)

      stock_transfers_new = StockTransferModel.get_all()
      assert 3 = Enum.count(stock_transfers_new)
    end
  end
end
