defmodule Snitch.Data.Model.ReturnAuthorizationReasonTest do
  @moduledoc false

  use ExUnit.Case, async: true
  use Snitch.DataCase
  import Snitch.Factory

  alias Snitch.Data.Model.ReturnAuthorizationReason, as: RARModel

  describe "create/1" do
    @tag :fail
    test "Fails for invalid attributes" do
      assert {:error, changeset} = RARModel.create(%{})
      refute changeset.valid?
      assert %{name: ["can't be blank"]} = errors_on(changeset)
    end

    @tag :pass
    test "inserts with valid attributes" do
      assert {:ok, _reason} = RARModel.create(%{name: "testing reason"})
    end
  end

  describe "get" do
    @tag :fail
    test "Fails for invalid id" do
      reason = RARModel.get(-1)
      assert nil == reason
    end

    @tag :pass
    test "gets with valid id" do
      reason = insert(:return_authorization_reason)

      get_reason = RARModel.get(reason.id)
      assert reason.id == get_reason.id

      get_reason_with_map = RARModel.get(%{id: reason.id})
      assert reason.id == get_reason_with_map.id
    end
  end

  describe "update" do
    @tag :fail
    test "without reason instance : Invalid attributes" do
      reason = insert(:return_authorization_reason)

      assert {:error, changeset} = RARModel.update(%{id: reason.id, name: ""})
      assert %{name: ["can't be blank"]} = errors_on(changeset)
    end

    @tag :pass
    test "without reason instance : valid attributes" do
      reason = insert(:return_authorization_reason)

      assert {:ok, updated_reason} = RARModel.update(%{id: reason.id, name: "any thing unique"})
      assert "any thing unique" = updated_reason.name
    end

    @tag :fail
    test "with instance : Invalid attributes" do
      reason = insert(:return_authorization_reason)

      assert {:error, changeset} = RARModel.update(%{name: ""}, reason)
      assert %{name: ["can't be blank"]} = errors_on(changeset)
    end

    @tag :pass
    test "with reason instance : valid attributes" do
      reason = insert(:return_authorization_reason)

      assert {:ok, updated_reason} = RARModel.update(%{name: "any thing unique"}, reason)
      assert "any thing unique" = updated_reason.name
    end
  end

  describe "delete/1" do
    test "Fails to delete if invalid id" do
      assert {:error, :not_found} = RARModel.delete(-1)
    end

    test "Deletes for valid id" do
      reason = insert(:return_authorization_reason)
      assert {:ok, _} = RARModel.delete(reason.id)
    end

    test "Deletes for valid Reason" do
      reason = insert(:return_authorization_reason)
      assert {:ok, _} = RARModel.delete(reason)
    end
  end

  describe "get_all/0" do
    test "fetches all the stock items" do
      reasons = RARModel.get_all()
      assert 0 = Enum.count(reasons)

      # add for multiple random variants
      insert_list(1, :return_authorization_reason)
      insert_list(2, :return_authorization_reason)

      stock_items_new = RARModel.get_all()
      assert 3 = Enum.count(stock_items_new)
    end
  end
end
