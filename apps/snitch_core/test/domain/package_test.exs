defmodule Snitch.Domain.PackageTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase

  import Mox, only: [expect: 4, verify_on_exit!: 1]
  import Snitch.Factory

  alias Snitch.Domain.Package
  alias Snitch.Data.Model.GeneralConfiguration, as: GCModel

  setup :states

  describe "set_shipping_method/2" do
    setup :zones
    setup :shipping_methods
    setup :embedded_shipping_methods

    setup %{embedded_shipping_methods: methods, states: states} do
      order = insert(:order, shipping_address: address_manifest(List.first(states)))
      tax_class_values = %{shipping_tax: %{class: insert(:tax_class), percent: 5}}
      setup_tax_with_zone_and_rates(tax_class_values, states)
      package = insert(:package, shipping_methods: methods)

      [package: package, order: order]
    end

    setup :verify_on_exit!

    @tag state_count: 3, shipping_method_count: 1
    test "with valid shipping method", context do
      %{package: package, shipping_methods: [sm], order: order} = context
      assert {:ok, package} = Package.set_shipping_method(package, sm.id, order)
      assert package.shipping_method_id
      assert package.cost
      assert package.shipping_tax
    end

    @tag shipping_method_count: 1
    test "with invalid shipping method", context do
      %{package: package, shipping_methods: [sm], order: order} = context

      assert {:error, cs} = Package.set_shipping_method(package, -1, order)
      assert %{shipping_method_id: ["can't be blank"]} == errors_on(cs)

      assert {:error, cs} = Package.set_shipping_method(package, sm.id + 1, order)
      assert %{shipping_method_id: ["can't be blank"]} == errors_on(cs)
    end
  end

  defp address_manifest(state) do
    %{
      first_name: "someone",
      last_name: "enoemos",
      address_line_1: "BR Ambedkar Chowk",
      address_line_2: "street",
      zip_code: "11111",
      city: "Rajendra Nagar",
      phone: "1234567890",
      country_id: state.country_id,
      state_id: state.id
    }
  end
end
