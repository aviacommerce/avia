defmodule Snitch.Data.Model.ShipmentUnitModelTest do
  @moduledoc false

  use ExUnit.Case, async: true
  use Snitch.DataCase
  import Snitch.Factory
  alias Snitch.Data.Model.ShipmentUnit, as: ShipmentUnitModel

  setup do
    [
      variant: insert(:variant),
      line_item: insert(:line_item)
    ]
  end

  describe "create/4" do
    test "Fails with invalid attributes", context do
      %{variant: variant, line_item: line_item} = context
      assert {:error, changeset} = ShipmentUnitModel.create("pending", true, 1, -1, variant.id)
      refute changeset.valid?
      assert %{line_item_id: ["does not exist"]} = errors_on(changeset)

      assert {:error, changeset} = ShipmentUnitModel.create("pending", true, 1, line_item.id, -1)
      refute changeset.valid?
      assert %{variant_id: ["does not exist"]} = errors_on(changeset)

      assert {:error, changeset} =
               ShipmentUnitModel.create(nil, true, 1, line_item.id, variant.id)

      refute changeset.valid?
      assert %{state: ["can't be blank"]} = errors_on(changeset)

      assert {:error, changeset} =
               ShipmentUnitModel.create("pending", true, -1, line_item.id, variant.id)

      refute changeset.valid?
      %{quantity: ["must be greater than -1"]} = errors_on(changeset)
    end

    test "Inserts with valid attributes", context do
      %{variant: variant, line_item: line_item} = context

      assert {:ok, shipment_unit} =
               ShipmentUnitModel.create("pending", true, 1, line_item.id, variant.id)

      assert shipment_unit.variant_id == variant.id
      assert shipment_unit.line_item_id == line_item.id
      assert shipment_unit.state == "pending"
      assert shipment_unit.pending == true
      assert shipment_unit.quantity == 1
    end
  end

  describe "get/1" do
    test "Fails with invalid id" do
      shipment_unit = ShipmentUnitModel.get(1)
      assert nil == shipment_unit
    end

    test "gets with valid id", context do
      %{variant: variant, line_item: line_item} = context
      insert_shipment_unit = insert(:shipment_unit, variant: variant, line_item: line_item)

      get_shipment_unit = ShipmentUnitModel.get(insert_shipment_unit.id)
      assert insert_shipment_unit.id == get_shipment_unit.id
      assert insert_shipment_unit.line_item_id == line_item.id
      assert insert_shipment_unit.quantity == get_shipment_unit.quantity
      assert insert_shipment_unit.state == get_shipment_unit.state
      assert insert_shipment_unit.variant_id == get_shipment_unit.variant_id

      # with stock item map
      get_shipment_unit_with_map = ShipmentUnitModel.get(%{id: insert_shipment_unit.id})
      assert insert_shipment_unit.id == get_shipment_unit_with_map.id
      assert insert_shipment_unit.line_item_id == line_item.id
      assert insert_shipment_unit.quantity == get_shipment_unit_with_map.quantity
      assert insert_shipment_unit.state == get_shipment_unit_with_map.state
      assert insert_shipment_unit.variant_id == get_shipment_unit_with_map.variant_id
    end
  end

  describe "get_all/0" do
    test "fetches all the shipment unit" do
      shipment_units = ShipmentUnitModel.get_all()
      assert 0 = Enum.count(shipment_units)

      # add for multiple random stock items
      insert_list(1, :shipment_unit)
      insert_list(2, :shipment_unit)

      shipment_units_new = ShipmentUnitModel.get_all()
      assert 3 = Enum.count(shipment_units_new)
    end
  end
end
