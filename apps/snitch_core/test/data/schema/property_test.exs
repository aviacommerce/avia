defmodule Snitch.Data.Schema.PropertyTest do
  use ExUnit.Case
  use Snitch.DataCase

  import Ecto.Changeset

  alias Snitch.Data.Schema.Property

  @valid_attrs %{name: "Sapphire Radeon", display_name: "processors"}

  describe "create_changeset/2" do
    test "with valid attributes" do
      %{valid?: validity} =  Property.create_changeset(%Property{}, @valid_attrs)
      assert validity
    end

    test "where name and display_name cannot be blank" do
      params = Map.delete(@valid_attrs, :name)
      cs = %{valid?: validity} = Property.create_changeset(%Property{}, params)
      refute validity
      assert %{name: ["can't be blank"]} = errors_on(cs)

      params = Map.delete(@valid_attrs, :display_name)
      cs = %{valid?: validity} = Property.create_changeset(%Property{}, params)
      refute validity
      assert %{display_name: ["can't be blank"]} = errors_on(cs)
    end

    test "where name must be unique" do
      changeset = Property.create_changeset(%Property{}, @valid_attrs)
      assert {:ok, _} = Repo.insert(changeset)

      changeset = Property.create_changeset(%Property{}, @valid_attrs)
      assert {:error, cs} = Repo.insert(changeset)
      assert %{name: ["has already been taken"]} == errors_on(cs)
    end
  end

  describe "update_changeset/2" do
    setup do
      [
        property:
          %Property{}
          |> Property.create_changeset(@valid_attrs)
          |> apply_changes()
      ]
    end

    test "with valid attributes", %{property: property} do
      params = %{name: "Corsair Power Supply", display_name: "AC input"}
      %{valid?: validity} = Property.update_changeset(property, params)
      assert validity
    end

    test "where name and display_name cannot be blank", %{property: property} do
      params = %{name: "", display_name: "AC input"}
      cs = %{valid?: validity} = Property.update_changeset(property, params)
      refute validity
      assert %{name: ["can't be blank"]} = errors_on(cs)

      params = %{name: "Corsair Power Supply", display_name: ""}
      cs = %{valid?: validity} = Property.update_changeset(property, params)
      refute validity
      assert %{display_name: ["can't be blank"]} = errors_on(cs)
    end

    test "where name must be unique", %{property: property} do
      params = %{name: "Corsair Power Supply", display_name: "AC input"}
      changeset = Property.update_changeset(property, params)
      assert {:ok, _} = Repo.insert(changeset)

      params = %{name: "Corsair Power Supply", display_name: "Safety Approvals"}
      changeset =  Property.update_changeset(property, params)
      assert {:error, cs} = Repo.insert(changeset)
      assert %{name: ["has already been taken"]} = errors_on(cs)
    end
  end
end
