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

  describe "create" do
    @tag state_zone_count: 1, country_zone_count: 1
    test "with valid params and zones", %{zones: zones} do
      {:ok, sm} = ShippingMethod.create(@valid_params, zones)
      assert Enum.count(sm.zones) == 2
    end

    test "with no zones" do
      {:ok, sm} = ShippingMethod.create(@valid_params, [])
      assert [] = sm.zones
    end
  end

  describe "update" do
    setup :shipping_methods

    @tag shipping_method_count: 1, state_zone_count: 1, country_zone_count: 1
    test "only params", %{shipping_methods: [sm]} do
      new_params = %{name: "bullock-cart"}
      {:ok, updated_sm} = ShippingMethod.update(sm, new_params, sm.zones)
      assert sm.zones == updated_sm.zones
      assert updated_sm.name == "bullock-cart"
    end

    @tag shipping_method_count: 1, state_zone_count: 1, country_zone_count: 1
    test "remove all zones", %{shipping_methods: [sm]} do
      new_params = %{name: "bullock-cart"}
      {:ok, updated_sm} = ShippingMethod.update(sm, new_params, [])
      assert [] = updated_sm.zones
    end

    @tag shipping_method_count: 1, state_zone_count: 1, country_zone_count: 1
    test "params and zones", %{shipping_methods: [sm]} do
      new_params = %{name: "bullock-cart"}
      {:ok, updated_sm} = ShippingMethod.update(sm, new_params, [])
      assert [] = updated_sm.zones
    end
  end
end
