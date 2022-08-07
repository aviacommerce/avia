defmodule Snitch.Data.Schema.PackageTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase

  import Ecto.Changeset, only: [fetch_change: 2, apply_changes: 1]

  alias Snitch.Data.Schema.{Package, ShippingMethod}

  @params %{
    number: "P01",
    state: "pending",
    shipping_methods: [%ShippingMethod{}],
    tracking: %{},
    order_id: 0,
    origin_id: 0,
    shipping_category_id: 0,
    shipping_method_id: nil
  }

  @item_params %{
    number: "PI01",
    state: "ready",
    quantity: 3,
    delta: 2,
    backordered?: false,
    product_id: 0,
    line_item_id: 0,
    tax: Money.zero(:USD),
    package_id: 0
  }

  describe "create_changeset/2" do
    test "with valid params" do
      assert cs = %{valid?: true} = Package.create_changeset(%Package{}, @params)
      assert :error = fetch_change(cs, :items)

      cs = Package.create_changeset(%Package{}, Map.put(@params, :items, [@item_params]))
      assert cs.valid?
      assert {:ok, items} = fetch_change(cs, :items)
      assert Enum.all?(items, fn %{action: :insert} -> true end)
    end

    test "fails with missing params" do
      cs = Package.create_changeset(%Package{}, %{})
      refute cs.valid?

      assert %{
               order_id: ["can't be blank"],
               origin_id: ["can't be blank"],
               shipping_category_id: ["can't be blank"],
               shipping_methods: ["can't be blank"],
               state: ["can't be blank"]
             } == errors_on(cs)
    end
  end

  @update_params %{
    shipping_methods: [],
    tracking: %{id: "some_tracking_id"},
    state: "ready",
    cost: Money.zero(:USD),
    shipping_tax: Money.zero(:USD),
    origin_id: -1,
    order_id: -1,
    shipping_method_id: 1,
    shipping_category_id: -1,
    number: "WHAT",
    shipped_at: DateTime.utc_now()
  }
  @shipping_params @update_params

  describe "shipping_changeset/2" do
    test "fails with missing params" do
      cs = Package.create_changeset(%Package{}, @params)
      assert cs.valid?
      package = apply_changes(cs)

      cs = Package.shipping_changeset(package, %{})
      refute cs.valid?

      assert %{
               shipping_tax: ["can't be blank"],
               cost: ["can't be blank"],
               shipping_method_id: ["can't be blank"]
             } == errors_on(cs)
    end

    test "with valid params" do
      cs = Package.create_changeset(%Package{}, @params)
      assert cs.valid?
      package = apply_changes(cs)

      cs = Package.shipping_changeset(package, @shipping_params)
      assert cs.valid?
    end
  end

  describe "update_changeset/2" do
    test "with valid params" do
      cs = Package.create_changeset(%Package{}, @params)
      assert cs.valid?
      package = apply_changes(cs)

      cs = Package.update_changeset(package, @update_params)
      assert cs.valid?
      assert apply_changes(cs).shipping_methods == []
    end

    test "with invalid params" do
      cs = Package.create_changeset(%Package{}, @params)
      assert cs.valid?
      package = apply_changes(cs)

      bad_params = %{
        shipping_methods: [1],
        tracking: 1
      }

      cs = Package.update_changeset(package, bad_params)
      refute cs.valid?
      assert {"is invalid", [type: :map, validation: :cast]} == cs.errors[:tracking]

      assert {"is invalid", [type: {:array, :map}]} == cs.errors[:shipping_methods]
    end
  end
end
