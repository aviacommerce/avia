defmodule Snitch.Data.Model.ShippingMethodTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase

  import Snitch.Factory
  import Ecto.Query

  alias Ecto.Query
  alias Snitch.Data.Model.ShippingMethod

  @valid_params %{
    slug: "shipping_method",
    name: "hyperloop",
    description: "Brought to you by spacex!"
  }

  setup :zones
  setup :shipping_categories
  setup :shipping_methods

  describe "create" do
    @tag state_zone_count: 1,
         country_zone_count: 1,
         shipping_category_count: 1
    test "with valid params and zones", context do
      %{zones: zones, shipping_categories: categories} = context
      {:ok, sm} = ShippingMethod.create(@valid_params, zones, categories)
      assert Enum.count(sm.zones) == 2
      assert Enum.count(sm.shipping_categories) == 1
    end

    test "with no zones or categories" do
      {:ok, sm} = ShippingMethod.create(@valid_params, [], [])
      assert [] = sm.zones
      assert [] = sm.shipping_categories
    end
  end

  describe "update" do
    @tag shipping_method_count: 1,
         state_zone_count: 1,
         country_zone_count: 1,
         shipping_category_count: 1
    setup :shipping_methods

    test "only params", %{shipping_methods: [sm]} do
      new_params = %{name: "bullock-cart"}
      {:ok, updated_sm} = ShippingMethod.update(sm, new_params, sm.zones, sm.shipping_categories)
      assert sm.zones == updated_sm.zones
      assert updated_sm.name == "bullock-cart"
    end

    @tag shipping_method_count: 1,
         state_zone_count: 1,
         country_zone_count: 1,
         shipping_category_count: 1
    test "remove all zones and categories", %{shipping_methods: [sm]} do
      new_params = %{name: "bullock-cart"}
      {:ok, updated_sm} = ShippingMethod.update(sm, new_params, [], [])
      assert [] = updated_sm.zones
    end

    @tag shipping_method_count: 1,
         state_zone_count: 1,
         country_zone_count: 1,
         shipping_category_count: 1
    test "params, zones and categories", %{shipping_methods: [sm]} do
      new_params = %{name: "bullock-cart"}
      {:ok, updated_sm} = ShippingMethod.update(sm, new_params, [], [])
      assert [] = updated_sm.zones
    end
  end

  describe "get/1" do
    @tag shipping_method_count: 1,
         state_zone_count: 1,
         country_zone_count: 1,
         shipping_category_count: 1
    test "returns the required shipping method with id", %{shipping_methods: [sm]} do
      {:ok, new_sm} = ShippingMethod.get(sm.id)
      assert new_sm.id == sm.id
    end

    @tag shipping_method_count: 1,
         state_zone_count: 1,
         country_zone_count: 1,
         shipping_category_count: 1
    test "returns the required shipping method with a map", %{shipping_methods: [sm]} do
      map = %{name: sm.name}
      {:ok, new_sm} = ShippingMethod.get(map)
      assert new_sm.id == sm.id
    end

    test "fails for invalid id" do
      assert {:error, :shipping_method_not_found} = ShippingMethod.get(-1)
    end
  end

  @tag shipping_method_count: 1,
       state_zone_count: 1,
       country_zone_count: 1,
       shipping_category_count: 1
  test "get_all/0 returns all the shipping methods succesfully", %{shipping_methods: [sm]} do
    sm_list = ShippingMethod.get_all()
    assert length(sm_list) == length([sm])
  end

  describe "delete/1" do
    @tag shipping_method_count: 1,
         state_zone_count: 1,
         country_zone_count: 1,
         shipping_category_count: 1
    test "successfully deletes a shipping method", %{shipping_methods: [sm]} do
      {:ok, _} = ShippingMethod.delete(sm.id)
      assert ShippingMethod.get(sm.id) == {:error, :shipping_method_not_found}
    end

    test "fails for invalid id" do
      assert {:error, :not_found} = ShippingMethod.delete(-1)
    end
  end

  @tag state_zone_count: 1,
       country_zone_count: 1,
       shipping_category_count: 1
  test "for_package_query/2 returns a valid query", %{
    zones: zones,
    shipping_categories: [categories]
  } do
    zone_ids = Enum.map(zones, &Map.get(&1, :id))

    expected =
      Query.from(s0 in "snitch_shipping_methods_zones",
        join: s1 in "snitch_shipping_methods_categories",
        on: s1.shipping_method_id == s0.shipping_method_id,
        join: s2 in Snitch.Data.Schema.ShippingMethod,
        on: s0.shipping_method_id == s2.id,
        where: s0.zone_id in ^zone_ids,
        where: s1.shipping_category_id == ^categories.id,
        distinct: [asc: s2.id],
        select: s2
      )

    result = ShippingMethod.for_package_query(zones, categories)

    assert inspect(result) == inspect(expected)
  end
end
