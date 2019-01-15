defmodule Snitch.Data.Schema.PropertyTest do
  use ExUnit.Case
  use Snitch.DataCase

  import Ecto.Changeset

  alias Snitch.Data.Schema.Property

  @valid_attrs %{name: "Milk", display_name: "Amul milk"}

  describe "Create property" do
    test "changeset with valid attributes" do
      %{valid?: validity} =  Property.create_changeset(%Property{},@valid_attrs)
      assert validity
    end

    test "name and display_name cannot be blank" do
      params = Map.delete(@valid_attrs, :name)
      cs = %{valid?: validity} = Property.create_changeset(%Property{},params)
      refute validity
      assert %{name: ["can't be blank"]} = errors_on(cs)

      params = Map.delete(@valid_attrs, :display_name)
      cs = %{valid?: validity} = Property.create_changeset(%Property{},params)
      refute validity
      assert %{display_name: ["can't be blank"]} = errors_on(cs)
    end

    test "name must be unique" do
      cset = Property.create_changeset(%Property{}, @valid_attrs)
      assert {:ok, _} = Repo.insert(cset)

      cset = Property.create_changeset(%Property{}, @valid_attrs)
      assert {:error, cs} = Repo.insert(cset)
      assert %{name: ["has already been taken"]} == errors_on(cs)
    end
  end

  describe "Update property" do
    setup do
      [
        property:
          %Property{}
          |> Property.create_changeset(@valid_attrs)
          |> apply_changes()
      ]
    end

    test "valid attributes", %{property: property} do
      params = %{name: "shoes",display_name: "Nike"}
      %{valid?: validity} = Property.update_changeset(property,params)
      assert validity
    end

    test "name and display_name cannot be blank", %{property: property} do
      params = %{name: "",display_name: "Nike"}
      cs = %{valid?: validity} = Property.update_changeset(property,params)
      refute validity
      assert %{name: ["can't be blank"]} = errors_on(cs)

      params = %{name: "Shoes",display_name: ""}
      cs = %{valid?: validity} = Property.update_changeset(property,params)
      refute validity
      assert %{display_name: ["can't be blank"]} = errors_on(cs)
    end

    test "name must be unique", %{property: property} do
      params = %{name: "Shoes",display_name: "Nike"}
      cset = Property.update_changeset(property,params)
      assert {:ok,_} = Repo.insert(cset)

      params = %{name: "Shoes",display_name: "Adidas"}
      cset =  Property.update_changeset(property,params)
      assert {:error,cs} = Repo.insert(cset)
      assert %{name: ["has already been taken"]} = errors_on(cs)
    end
  end
end
