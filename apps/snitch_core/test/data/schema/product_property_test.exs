defmodule Snitch.Data.Schema.ProductPropertyTest do
  use ExUnit.Case, async: true
  import Snitch.Factory
  use Snitch.DataCase
  alias Snitch.Data.Schema.ProductProperty

  setup do
    product = insert(:product)
    property = insert(:property)

    valid_attrs = %{
      product_id: product.id,
      property_id: property.id,
      value: "val"
    }

    invalid_attrs = %{
      product_id: "",
      property_id: "",
      val: ""
    }

    [valid_attrs: valid_attrs, invalid_attrs: invalid_attrs]
  end

  test "create successfully", %{valid_attrs: va} do
    %{valid?: validity} = ProductProperty.create_changeset(%ProductProperty{}, va)
    assert validity
  end

  test "create unsuccessful if name empty", %{invalid_attrs: iva} do
    %{valid?: validity} = ProductProperty.create_changeset(%ProductProperty{}, iva)
    refute validity
  end

  test "update successfully", %{valid_attrs: va} do
    cset = %{valid?: validity} = ProductProperty.create_changeset(%ProductProperty{}, va)
    assert validity
    assert {:ok, product_property} = Repo.insert(cset)

    params = %{value: "new value"}
    cset = ProductProperty.update_changeset(product_property, params)
    assert {:ok, new_product_property} = Repo.update(cset)
    assert new_product_property.value != product_property.value
  end

  test "update unsuccessful", %{valid_attrs: va, invalid_attrs: iva} do
    cset = %{valid?: validity} = ProductProperty.create_changeset(%ProductProperty{}, va)
    assert validity
    assert {:ok, product_property} = Repo.insert(cset)

    cset = %{valid?: update_validity} = ProductProperty.update_changeset(product_property, iva)
    refute update_validity
    assert {:error, _} = Repo.update(cset)
  end
end
