defmodule Snitch.Data.Model.ProductPropertyTest do
  use ExUnit.Case
  use Snitch.DataCase

  import Snitch.Factory

  alias Snitch.Data.Model.ProductProperty
  alias Snitch.Data.Schema.ProductProperty, as: ProductPropertySchema

  setup :product_property

  setup do
    product = insert(:product)
    property = insert(:property)

    valid_attrs = %{
      product_id: product.id,
      property_id: property.id,
      value: "val"
    }

    [valid_attrs: valid_attrs]
  end

  describe "create/1" do
    test "successfully with valid attributes", %{valid_attrs: valid_attrs} do
      assert {:ok, %ProductPropertySchema{}} = ProductProperty.create(valid_attrs)
    end

    test "fails for duplicate property", %{params: params} do
      assert {:error, _} = ProductProperty.create(params)
    end
  end

  describe "update/2" do
    test "successfully along with property", %{product_property: product_property} do
      params = %{value: "val"}
      {:ok, updated_product_property} = ProductProperty.update(product_property, params)

      assert updated_product_property.id == product_property.id
      assert updated_product_property.value == "val"
    end

    test "unsuccessfully along with property", %{valid_attrs: valid_attrs} do
      {:ok, product_property} = ProductProperty.create(valid_attrs)
      property = insert(:property)

      {:ok, product_property_new} =
        ProductProperty.create(%{
          property_id: property.id,
          product_id: product_property.product_id,
          value: "value"
        })

      assert {:error, _} =
               ProductProperty.update(product_property_new, %{
                 property_id: product_property.property_id
               })
    end
  end

  describe "delete/1" do
    test "deletes a product property", %{product_property: product_property} do
      {:ok, _} = ProductProperty.delete(product_property)
      assert Repo.get(ProductPropertySchema, product_property.id) == nil
    end

    test "deletes a product property with id", %{product_property: product_property} do
      {:ok, _} = ProductProperty.delete(product_property.id)
      assert Repo.get(ProductPropertySchema, product_property.id) == nil
    end

    test "failed not found" do
      assert {:error, :not_found} = ProductProperty.delete(-1)
    end
  end

  describe "get/1" do
    test "product property with id", %{product_property: product_property} do
      {:ok, product_property_returned} = ProductProperty.get(product_property.id)
      assert product_property_returned.id == product_property.id
    end
  end

  describe "get_all/0" do
    test "product properties", %{product_property: product_property} do
      assert ProductProperty.get_all() != []
    end
  end

  describe "get_by/1" do
    test "product property", %{product_property: product_property} do
      {:ok, product_property_returned} = ProductProperty.get_by(product_property.id)
      assert product_property_returned.id == product_property.id
    end
  end

  describe "get_all_by_product/1" do
    test "with product_id", %{product_property: product_property} do
      product_property_by_product =
        ProductProperty.get_all_by_product(product_property.product_id) |> List.first()

      assert product_property_by_product.id == product_property.id
    end
  end

  describe "get_all_by_property/1" do
    test "with property_id", %{product_property: product_property} do
      product_property_by_property =
        ProductProperty.get_all_by_property(product_property.property_id) |> List.first()

      assert product_property_by_property.id == product_property.id
    end
  end

  defp product_property(context) do
    product_property = insert(:product_property)

    params = %{
      product_id: product_property.product_id,
      property_id: product_property.property_id,
      value: product_property.value
    }

    [params: params, product_property: product_property]
  end
end
