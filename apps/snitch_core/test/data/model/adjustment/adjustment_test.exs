defmodule Snitch.Data.Model.AdjustmentTest do
  @moduledoc false

  use ExUnit.Case
  use Snitch.DataCase
  import Snitch.Factory
  alias Snitch.Data.Model.Adjustment

  describe "create/1" do
    test "fails for missing params" do
      params = %{}

      assert {:error, changeset} = Adjustment.create(params)

      assert %{
               adjustable_id: ["can't be blank"],
               adjustable_type: ["can't be blank"],
               amount: ["can't be blank"]
             } == errors_on(changeset)
    end

    test "fails if adjustable_type not valid" do
      params = %{adjustable_type: :xyz, adjustable_id: 1, amount: Decimal.new(-10)}

      assert {:error, changeset} = Adjustment.create(params)
      assert %{adjustable_type: ["is invalid"]} == errors_on(changeset)
    end
  end

  describe "update/1" do
    test "updates successfully" do
      line_item = insert(:line_item)

      params = %{
        adjustable_type: :line_item,
        adjustable_id: line_item.id,
        amount: Decimal.new(-10)
      }

      {:ok, adjustment} = Adjustment.create(params)
      assert adjustment.eligible == false

      update_params = %{eligible: true}
      assert {:ok, updated_adjustment} = Adjustment.update(update_params, adjustment)
      assert updated_adjustment.eligible == true
    end
  end
end
