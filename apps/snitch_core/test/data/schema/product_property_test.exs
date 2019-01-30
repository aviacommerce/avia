defmodule Snitch.Data.Schema.ProductPropertyTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase

  import Snitch.Factory

  alias Snitch.Data.Schema.ProductProperty

  setup do
    product_property = insert(:product_property)

    params = %{
      product_id: product_property.product_id,
      property_id: product_property.property_id,
      value: product_property.value
    }

    [params: params, product_property: product_property]
  end

  describe "create_changeset/2" do
    test "successfully with valid params", %{params: params} do
      cs = ProductProperty.create_changeset(%ProductProperty{}, params)
      assert cs.valid?
    end

    test "fails with invalid params" do
      cs = ProductProperty.create_changeset(%ProductProperty{}, %{})
      refute cs.valid?

      assert %{
               product_id: ["can't be blank"],
               property_id: ["can't be blank"],
               value: ["can't be blank"]
             } == errors_on(cs)
    end

    test "fails for duplicate product_id", %{params: params} do
      cs = ProductProperty.create_changeset(%ProductProperty{}, params)
      {:error, changeset} = Repo.insert(cs)
      assert %{property_id: ["has already been taken"]} == errors_on(changeset)
    end

    test "fails for non-existent product_id" do
      params = %{
        product_id: -1,
        property_id: 1,
        value: "val"
      }

      cs = ProductProperty.create_changeset(%ProductProperty{}, params)
      {:error, changeset} = Repo.insert(cs)
      assert %{product_id: ["does not exist"]} == errors_on(changeset)
    end

    test "fails for non-existent property_id", %{params: params} do
      params = %{
        product_id: params.product_id,
        property_id: -1,
        value: "val"
      }

      cs = ProductProperty.create_changeset(%ProductProperty{}, params)
      {:error, changeset} = Repo.insert(cs)
      assert %{property_id: ["does not exist"]} == errors_on(changeset)
    end
  end

  describe "update_changeset/2" do
    test "successfully with valid params", %{product_property: product_property} do
      params = %{value: "val"}
      updated_changeset = ProductProperty.update_changeset(product_property, params)
      assert updated_changeset.valid?
    end

    test "fails for invalid params", %{product_property: product_property} do
      params = %{property_id: nil, value: ""}
      updated_changeset = ProductProperty.update_changeset(product_property, params)

      assert %{property_id: ["can't be blank"], value: ["can't be blank"]} ==
               errors_on(updated_changeset)
    end
  end
end
