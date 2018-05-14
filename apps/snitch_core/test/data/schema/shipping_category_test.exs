defmodule Snitch.Data.Schema.ShippingCategoryTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase

  alias Snitch.Data.Schema.ShippingCategory

  @valid_params %{
    name: "ship-it-fast!"
  }

  @update_params %{
    name: "ship-it-in-a-spacex-rocket!"
  }

  describe "create_changeset/2 " do
    test "with valid params" do
      %{valid?: validity} = ShippingCategory.create_changeset(%ShippingCategory{}, @valid_params)
      assert validity
    end

    test "fails with duplicate name" do
      %ShippingCategory{}
      |> ShippingCategory.create_changeset(@valid_params)
      |> Repo.insert!()

      cs =
        %{valid?: validity} =
        ShippingCategory.create_changeset(%ShippingCategory{}, @valid_params)

      assert validity
      assert {:error, cs} = Repo.insert(cs)
      assert %{name: ["has already been taken"]} = errors_on(cs)
    end
  end

  describe "update_changeset/2 " do
    setup do
      [
        shipping_category:
          %ShippingCategory{}
          |> ShippingCategory.create_changeset(@valid_params)
          |> Repo.insert!()
      ]
    end

    test "with valid params", %{shipping_category: sc} do
      cs = %{valid?: validity} = ShippingCategory.update_changeset(sc, @update_params)
      assert validity
      assert {:ok, _} = Repo.update(cs)
    end

    test "fails with duplicate name", %{shipping_category: sc} do
      %ShippingCategory{}
      |> ShippingCategory.create_changeset(@update_params)
      |> Repo.insert!()

      cs = %{valid?: validity} = ShippingCategory.update_changeset(sc, @update_params)
      assert validity
      assert {:error, cs} = Repo.update(cs)
      assert %{name: ["has already been taken"]} = errors_on(cs)
    end
  end
end
