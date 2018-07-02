defmodule Snitch.Domain.PackageTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase

  import Mox, only: [expect: 3, verify_on_exit!: 1]
  import Snitch.Factory

  alias Snitch.Domain.Package

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
      expect(Snitch.Tools.DefaultsMock, :fetch, fn :currency -> {:ok, :USD} end)
      assert {:ok, package} = Package.set_shipping_method(package, sm.id)
      assert package.shipping_method_id
      assert package.cost
      assert package.tax_total
      assert package.promo_total
      assert package.adjustment_total
      assert package.total
    end

    @tag shipping_method_count: 1
    test "with invalid shipping method", %{package: package, shipping_methods: [sm]} do
      expect(Snitch.Tools.DefaultsMock, :fetch, fn :currency -> {:ok, :USD} end)
      assert {:error, cs} = Package.set_shipping_method(package, -1)
      assert %{shipping_method_id: ["can't be blank"]} == errors_on(cs)

      expect(Snitch.Tools.DefaultsMock, :fetch, fn :currency -> {:ok, :USD} end)
      assert {:error, cs} = Package.set_shipping_method(package, sm.id + 1)
      assert %{shipping_method_id: ["can't be blank"]} == errors_on(cs)
    end
  end
end
