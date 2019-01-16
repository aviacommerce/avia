defmodule Snitch.Data.Model.PropertyTest do
  use ExUnit.Case
  use Snitch.DataCase

  import Snitch.Factory
  alias Snitch.Data.Model.Property
  alias Snitch.Data.Schema.Property, as: PropertySchema

  @params %{
    name: "Sapphire Radeon",
    display_name: "processors"
  }

  describe "create/2" do
    test "with valid attributes" do
      assert {:ok, _} = Property.create(@params)
    end

    test "fails for duplicate name" do
      property = insert(:property)
      params = %{name: property.name, display_name: "AC Input"}
      assert {:error, changeset} = Property.create(params)
      assert %{name: ["has already been taken"]} = errors_on(changeset)
    end
  end

  describe "update/2" do
    test "with valid parameters " do
      property = insert(:property)
      %{id: expected_id} = property
      updates = %{name: "Amazon TV"}
      assert {:ok, %{id: received_id}} = Property.update(property, updates)
      assert expected_id == received_id
    end
  end

    test "get property" do
      property = insert(:property)
      assert property_returned = Property.get(property.id)
      assert property_returned = property
      assert {:ok, _} = Property.delete(property.id)
      assert Property.get(property.id) == nil
    end

    test "get all properties" do
      insert(:property)
      assert Property.get_all() != []
    end

  describe "delete/1" do
    test "a property" do
      property = insert(:property)
      assert {:ok, _} = Property.delete(property)
      assert Repo.get(PropertySchema, property.id) == nil
    end

    test "failed because no such property is present" do
      assert {:error, :not_found} = Property.delete(-1)
    end
  end

  describe "format/0" do
    test "for all properties" do
      properties = insert_list(1, :property)
      property = properties |> List.first()
      property_list = Property.get_formatted_list()
      assert property_list == [{property.display_name, property.id}]
    end
  end
end
