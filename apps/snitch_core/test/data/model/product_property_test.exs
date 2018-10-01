defmodule Snitch.Data.Model.ProductPropertyTest do
  use ExUnit.Case
  use Snitch.DataCase
  import Snitch.Factory
  alias Snitch.Data.Model.ProductProperty
  alias Snitch.Data.Schema.ProductProperty, as: ProductPropertySchema

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

  describe "create" do
    test "successfully", %{valid_attrs: va} do
      assert {:ok, %ProductPropertySchema{}} = ProductProperty.create(va)
    end

    test "creation fails for duplicate property", %{valid_attrs: va} do
      ProductProperty.create(va)
      assert {:error, _} = ProductProperty.create(va)
    end
  end

  describe "udpate" do
    test "successfully along with property", %{valid_attrs: va} do
      {:ok, product_property} = ProductProperty.create(va)
      property = insert(:property)

      assert {:ok, updated_product_property} =
               ProductProperty.update(product_property, %{property_id: property.id})

      assert updated_product_property.property_id == property.id
    end

    test "unsuccessfully along with property", %{valid_attrs: va} do
      {:ok, product_property} = ProductProperty.create(va)
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

  describe "delete" do
    test "delete a product property" do
      product_property = insert(:product_property)
      assert {:ok, _} = ProductProperty.delete(product_property)
      assert Repo.get(ProductPropertySchema, product_property.id) == nil
    end

    test "deletion failed not found" do
      assert {:error, :not_found} = ProductProperty.delete(-1)
    end
  end

  describe "get" do
    test "get product property" do
      product_property = insert(:product_property)
      assert product_property_returned = ProductProperty.get(product_property.id)
      assert product_property_returned.id == product_property.id
      assert {:ok, _} = ProductProperty.delete(product_property)
      assert ProductProperty.get(product_property.id) == nil
    end

    test "get all product properties" do
      insert(:product_property)
      assert ProductProperty.get_all() != []
    end
  end

  describe "get by" do
    test "get product property" do
      product_property = insert(:product_property)

      assert product_property_returned =
               ProductProperty.get_by(%{
                 product_id: product_property.product_id,
                 property_id: product_property.property_id
               })

      assert product_property_returned.id == product_property.id
    end
  end

  describe "get all by" do
    test "get product property" do
      product_property = insert(:product_property)

      assert product_property_by_product =
               ProductProperty.get_all_by_product(product_property.product_id) |> List.first()

      assert product_property_by_property =
               ProductProperty.get_all_by_property(product_property.property_id) |> List.first()

      assert product_property_by_product.id == product_property.id
      assert product_property_by_property.id == product_property.id
    end
  end
end
