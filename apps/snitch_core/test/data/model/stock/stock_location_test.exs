defmodule Snitch.Data.Model.StockLocationTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase
  import Snitch.Factory
  alias Snitch.Data.Model.StockLocation, as: StockLocationModel

  describe "create/4" do
    test "Fails for blank attributes" do
      assert {:error, changeset} =
               StockLocationModel.create(%{
                 name: "",
                 address_line_1: "",
                 state_id: nil,
                 country_id: nil
               })

      assert %{
               address_line_1: ["can't be blank"],
               country_id: ["can't be blank"],
               name: ["can't be blank"],
               state_id: ["can't be blank"]
             } = errors_on(changeset)
    end

    test "Fails for invalid associations" do
      assert {:error, changeset} =
               StockLocationModel.create(%{
                 name: "Diagon Alley",
                 address_line_1: "Street 10 London",
                 state_id: -1,
                 country_id: -1
               })

      assert %{state_id: ["does not exist"]} = errors_on(changeset)

      state = insert(:state)

      assert {:error, changeset} =
               StockLocationModel.create(%{
                 name: "Diagon Alley",
                 address_line_1: "Street 10 London",
                 state_id: state.id,
                 country_id: -1
               })

      assert %{country_id: ["does not exist"]} = errors_on(changeset)
    end

    test "Inserts with valid attributes" do
      assert {:ok, _stock_location} =
               StockLocationModel.create(%{
                 name: "Diagon Alley",
                 address_line_1: "Street 10 London",
                 state_id: insert(:state).id,
                 country_id: insert(:country).id
               })
    end
  end

  describe "get/1" do
    test "Fails with invalid id" do
      stock_location = StockLocationModel.get(-1)
      assert {:error, :stock_location_not_found} == stock_location
    end

    test "gets with valid id" do
      insert_stock_location = insert(:stock_location)

      {:ok, get_stock_location} = StockLocationModel.get(insert_stock_location.id)
      assert insert_stock_location.id == get_stock_location.id
      assert insert_stock_location.name == get_stock_location.name

      # with stock location map
      {:ok, get_stock_location_with_map} = StockLocationModel.get(%{id: insert_stock_location.id})
      assert insert_stock_location.id == get_stock_location_with_map.id
      assert insert_stock_location.name == get_stock_location_with_map.name
    end
  end

  describe "update/2" do
    test "without instance object params : Fails for INVALID attributes" do
      stock_location = insert(:stock_location)

      assert {:error, changeset} =
               StockLocationModel.update(%{name: "", address_line_1: "", id: stock_location.id})

      assert %{
               name: ["can't be blank"],
               address_line_1: ["can't be blank"]
             } = errors_on(changeset)
    end

    test "without instance object params : updates for VALID attributes" do
      stock_location = insert(:stock_location)

      assert {:ok, updated_stock_location} =
               StockLocationModel.update(%{name: "Updated New", id: stock_location.id})

      assert stock_location.name != updated_stock_location.name
    end

    test "with instance object params : Fails for INVALID attributes" do
      stock_location = insert(:stock_location)

      assert {:error, changeset} =
               StockLocationModel.update(%{name: "", address_line_1: ""}, stock_location)

      assert %{
               name: ["can't be blank"],
               address_line_1: ["can't be blank"]
             } = errors_on(changeset)
    end

    test "with instance object params : updates for VALID attributes" do
      stock_location = insert(:stock_location)

      assert {:ok, updated_stock_location} =
               StockLocationModel.update(%{name: "Updated New"}, stock_location)

      assert stock_location.name != updated_stock_location.name
    end
  end

  describe "delete/1" do
    test "Fails to delete if invalid id" do
      assert {:error, :not_found} = StockLocationModel.delete(-1)
    end

    test "Deletes for valid id" do
      stock_location = insert(:stock_location)
      assert {:ok, _} = StockLocationModel.delete(stock_location.id)
    end

    test "Deletes for valid stock location" do
      stock_location = insert(:stock_location)
      assert {:ok, _} = StockLocationModel.delete(stock_location)
    end
  end

  describe "active/0" do
    test "fetch all active stock locations" do
      insert_list(2, :stock_location)
      insert(:stock_location, active: false)
      assert Enum.count(StockLocationModel.active()) == 2
    end
  end
end
