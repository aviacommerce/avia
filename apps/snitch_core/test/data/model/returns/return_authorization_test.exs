defmodule Snitch.Data.Model.ReturnAuthorizationTest do
  @moduledoc false

  use ExUnit.Case, async: true
  use Snitch.DataCase
  import Snitch.Factory

  alias Snitch.Data.Model.ReturnAuthorization, as: RAModel

  setup do
    [
      order: insert(:order, user_id: insert(:user).id),
      return_authorization_reason: insert(:return_authorization_reason)
    ]
  end

  describe "create/1" do
    @tag :fail
    test "Fails for invalid attributes" do
      assert {:error, changeset} = RAModel.create(%{})
      refute changeset.valid?
      assert %{number: ["can't be blank"]} = errors_on(changeset)

      assert {:error, changeset} = RAModel.create(%{number: "R12321323"})
      refute changeset.valid?

      assert %{
               state: ["can't be blank"],
               return_authorization_reason_id: ["can't be blank"],
               order_id: ["can't be blank"]
             } = errors_on(changeset)
    end

    @tag :pass
    test "inserts with valid attributes", context do
      %{order: order, return_authorization_reason: return_authorization_reason} = context

      assert {:ok, _reason} =
               RAModel.create(%{
                 number: "R12321323",
                 state: "Test",
                 order_id: order.id,
                 return_authorization_reason_id: return_authorization_reason.id
               })
    end
  end

  describe "get" do
    @tag :fail
    test "Fails for invalid id" do
      reason = RAModel.get(-1)
      assert nil == reason
    end

    @tag :pass
    test "gets with valid id" do
      reason = insert(:return_authorization)

      get_reason = RAModel.get(reason.id)
      assert reason.id == get_reason.id

      get_reason_with_map = RAModel.get(%{id: reason.id})
      assert reason.id == get_reason_with_map.id
    end
  end

  describe "update" do
    @tag :fail
    test "without reason instance : Invalid attributes" do
      reason = insert(:return_authorization)

      assert {:error, changeset} = RAModel.update(%{id: reason.id, number: ""})
      assert %{number: ["can't be blank"]} = errors_on(changeset)
    end

    @tag :pass
    test "without reason instance : valid attributes" do
      reason = insert(:return_authorization)

      assert {:ok, updated_reason} = RAModel.update(%{id: reason.id, number: "any thing unique"})
      assert "any thing unique" = updated_reason.number
    end

    @tag :fail
    test "with instance : Invalid attributes" do
      reason = insert(:return_authorization)

      assert {:error, changeset} = RAModel.update(%{number: ""}, reason)
      assert %{number: ["can't be blank"]} = errors_on(changeset)
    end

    @tag :pass
    test "with reason instance : valid attributes" do
      reason = insert(:return_authorization)

      assert {:ok, updated_reason} = RAModel.update(%{number: "any thing unique"}, reason)
      assert "any thing unique" = updated_reason.number
    end
  end

  describe "delete/1" do
    test "Fails to delete if invalid id" do
      assert {:error, :not_found} = RAModel.delete(-1)
    end

    test "Deletes for valid id" do
      reason = insert(:return_authorization)
      assert {:ok, _} = RAModel.delete(reason.id)
    end

    test "Deletes for valid Reason" do
      reason = insert(:return_authorization)
      assert {:ok, _} = RAModel.delete(reason)
    end
  end

  describe "get_all/0" do
    test "fetches all the Authorizations" do
      reasons = RAModel.get_all()
      assert 0 = Enum.count(reasons)

      # add for multiple random variants
      insert_list(1, :return_authorization)
      insert_list(2, :return_authorization)

      authorizations_new = RAModel.get_all()
      assert 3 = Enum.count(authorizations_new)
    end
  end
end
