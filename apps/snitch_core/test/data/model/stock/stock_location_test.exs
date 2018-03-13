defmodule Snitch.Data.Model.StockLocationTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase
  import Snitch.Factory
  alias Snitch.Data.Model

  describe "create/4" do
    test "Fails for blank attributes" do
      assert {:error, changeset} = Model.StockLocation.create("", "", nil, nil)

      assert [
               name: {"can't be blank", [validation: :required]},
               address_line_1: {"can't be blank", [validation: :required]},
               state_id: {"can't be blank", [validation: :required]},
               country_id: {"can't be blank", [validation: :required]}
             ] = changeset
    end

    test "Fails for invalid associations" do
      assert {:error, changeset} =
               Model.StockLocation.create("Digon Alley", "Street 10 London", 1, 1)

      assert %{state_id: ["does not exist"]} = errors_on(changeset)

      state = insert(:state)

      assert {:error, changeset} =
               Model.StockLocation.create("Digon Alley", "Street 10 London", state.id, 1)

      assert %{country_id: ["does not exist"]} = errors_on(changeset)
    end

    test "Inserts with valid attributes" do
      assert {:ok, stock_location} =
               Model.StockLocation.create(
                 "Digon Alley",
                 "Street 10 London",
                 insert(:state).id,
                 insert(:country).id
               )
    end
  end

  describe "get/1" do
    test "Fails with invalid id" do
      stock_location = Model.StockLocation.get(1)
      assert nil == stock_location
    end

    test "gets with valid id" do
      insert_stock_location = insert(:stock_location)

      get_stock_location = Model.StockLocation.get(insert_stock_location.id)
      assert insert_stock_location.id == get_stock_location.id
      assert insert_stock_location.name == get_stock_location.name

      # with stock location map
      get_stock_location_with_map = Model.StockLocation.get(%{id: insert_stock_location.id})
      assert insert_stock_location.id == get_stock_location_with_map.id
      assert insert_stock_location.id == get_stock_location_with_map.id
      assert insert_stock_location.name == get_stock_location_with_map.name
    end
  end

  describe "update/2" do
    test "without instance object params : Fails for INVALID attributes" do
      stock_location = insert(:stock_location)

      assert {:error, changeset} =
               Model.StockLocation.update(%{name: "", address_line_1: "", id: stock_location.id})

      assert [
               name: {"can't be blank", [validation: :required]},
               address_line_1: {"can't be blank", [validation: :required]}
             ] = changeset
    end

    test "without instance object params : updates for VALID attributes" do
      stock_location = insert(:stock_location)

      assert {:ok, updated_stock_location} =
               Model.StockLocation.update(%{name: "Updated New", id: stock_location.id})

      assert stock_location.name != updated_stock_location.name
    end

    test "with instance object params : Fails for INVALID attributes" do
      stock_location = insert(:stock_location)

      assert {:error, changeset} =
               Model.StockLocation.update(%{name: "", address_line_1: ""}, stock_location)

      assert [
               name: {"can't be blank", [validation: :required]},
               address_line_1: {"can't be blank", [validation: :required]}
             ] = changeset
    end

    test "with instance object params : updates for VALID attributes" do
      stock_location = insert(:stock_location)

      assert {:ok, updated_stock_location} =
               Model.StockLocation.update(%{name: "Updated New"}, stock_location)

      assert stock_location.name != updated_stock_location.name
    end
  end

  describe "delete/1" do
    test "Fails to delete if invalid id" do
      assert {:error, :not_found} = Model.StockLocation.delete(1_234_567_890)
    end

    test "Deletes for valid id" do
      stock_location = insert(:stock_location)
      assert stock_location = Model.StockLocation.delete(stock_location.id)
    end

    test "Deletes for valid stock location" do
      stock_location = insert(:stock_location)
      assert stock_location = Model.StockLocation.delete(stock_location)
    end
  end

  describe "get_all/0" do
    test "fetch all stock locations" do
      insert_list(1, :stock_location, active: false)
      insert_list(2, :stock_location)

      stock_locations = Model.StockLocation.get_all()
      assert 3 = Enum.count(stock_locations)
    end
  end

  describe "active/0" do
    test "fetch all active stock locations" do
      insert_list(2, :stock_location)
      insert(:stock_location, active: false)
      assert 2 = Enum.count(Model.StockLocation.active())
    end
  end
end
