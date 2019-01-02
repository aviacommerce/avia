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
end
