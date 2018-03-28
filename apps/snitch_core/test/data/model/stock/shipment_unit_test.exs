defmodule Snitch.Data.Model.ShipmentUnitModelTest do
  @moduledoc false

  use ExUnit.Case, async: true
  use Snitch.DataCase
  import Snitch.Factory
  alias Snitch.Data.Model.ShipmentUnit, as: ShipmentUnitModel

  setup :user_with_address
  setup :an_order
  setup :variants
  setup :line_items

  describe "create/4" do
    @tag variant_count: 1
    test "fails with invalid attributes", context do
      %{line_items: [line_item]} = context

      assert {:error, changeset} =
               ShipmentUnitModel.create("pending", 1, -1, line_item.variant_id)

      refute changeset.valid?
      assert %{line_item_id: ["does not exist"]} = errors_on(changeset)

      assert {:error, changeset} = ShipmentUnitModel.create("pending", 1, line_item.id, -1)
      refute changeset.valid?
      assert %{variant_id: ["does not exist"]} = errors_on(changeset)

      assert {:error, changeset} =
               ShipmentUnitModel.create(nil, 1, line_item.id, line_item.variant_id)

      refute changeset.valid?
      assert %{state: ["can't be blank"]} = errors_on(changeset)

      assert {:error, changeset} =
               ShipmentUnitModel.create("pending", -1, line_item.id, line_item.variant_id)

      refute changeset.valid?
      %{quantity: ["must be greater than -1"]} = errors_on(changeset)
    end

    @tag variant_count: 1
    test "inserts with valid attributes", context do
      %{line_items: [line_item]} = context

      assert {:ok, shipment_unit} =
               ShipmentUnitModel.create("pending", 1, line_item.id, line_item.variant_id)

      assert shipment_unit.variant_id == line_item.variant_id
      assert shipment_unit.line_item_id == line_item.id
      assert shipment_unit.state == "pending"
      assert shipment_unit.quantity == 1
    end
  end
end
