defmodule Snitch.Data.Model.ShippingMethodTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase

  import Snitch.Factory

  alias Snitch.Data.Model.ShippingMethod

  @valid_params %{
    slug: "shipping_method",
    name: "hyperloop",
    description: "Brought to you by spacex!"
  }

  setup :zones
  setup :shipping_categories

  describe "create" do
    @tag state_zone_count: 1, country_zone_count: 1, shipping_category_count: 1
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
end
