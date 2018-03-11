defmodule Snitch.Data.Model.StockTransferTest do
  @moduledoc false

  use ExUnit.Case, async: true
  use Snitch.DataCase
  import Snitch.Factory
  alias Snitch.Data.Model.StockTransfer, as: StockTransferModel

  describe "create/4" do
    test "fails for missing reference or number" do
      assert {:error, changeset} = StockTransferModel.create("", "", -1, -1)
      refute changeset.valid?
      assert %{number: ["can't be blank"], reference: ["can't be blank"]} = errors_on(changeset)
    end

    test "fails with invalid source location" do
      assert {:error, changeset} = StockTransferModel.create("Ref", "T123", -1, -1)
      refute changeset.valid?
      assert %{source_id: ["does not exist"]} = errors_on(changeset)
    end

    test "with valid attributes" do
      stock_location = insert(:stock_location)

      assert {:ok, stock_transfer} =
               StockTransferModel.create("Ref", "T123", stock_location.id, stock_location.id)

      assert stock_transfer.destination_id == stock_location.id
    end
  end
end
