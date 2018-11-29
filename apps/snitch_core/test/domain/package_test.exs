defmodule Snitch.Domain.PackageTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase

  import Mox, only: [expect: 4, verify_on_exit!: 1]
  import Snitch.Factory

  alias Snitch.Domain.Package
  alias Snitch.Data.Model.GeneralConfiguration, as: GCModel

  describe "set_shipping_method/2" do
    setup :zones
    setup :shipping_methods
    setup :embedded_shipping_methods

    setup %{embedded_shipping_methods: methods} do
      [package: insert(:package, shipping_methods: methods)]
    end

    setup :verify_on_exit!

    @tag shipping_method_count: 1
    test "with valid shipping method", %{package: package, shipping_methods: [sm]} do
      assert {:ok, package} = Package.set_shipping_method(package, sm.id)
      assert package.shipping_method_id
      assert package.cost
      assert package.shipping_tax
    end

    @tag shipping_method_count: 1
    test "with invalid shipping method", %{package: package, shipping_methods: [sm]} do
      assert {:error, cs} = Package.set_shipping_method(package, -1)
      assert %{shipping_method_id: ["can't be blank"]} == errors_on(cs)

      assert {:error, cs} = Package.set_shipping_method(package, sm.id + 1)
      assert %{shipping_method_id: ["can't be blank"]} == errors_on(cs)
    end
  end

  test "shipping_tax/1" do
    currency = GCModel.fetch_currency()
    assert Package.shipping_tax(nil) == Money.zero(currency)
  end
end
