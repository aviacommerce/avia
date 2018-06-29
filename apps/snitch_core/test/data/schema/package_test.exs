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
    variant_id: 0,
    line_item_id: 0,
    package_id: 0
  }

  describe "create_changeset/2" do
    test "with valid params" do
      assert cs = %{valid?: true} = Package.create_changeset(%Package{}, @params)
      assert :error = fetch_change(cs, :items)

      assert cs =
               %{valid?: true} =
               Package.create_changeset(%Package{}, Map.put(@params, :items, [@item_params]))

      assert {:ok, items} = fetch_change(cs, :items)
      assert Enum.all?(items, fn %{action: :insert} -> true end)
    end

    test "fails with missing params" do
      assert cs = %{valid?: false} = Package.create_changeset(%Package{}, %{})

      assert %{
               order_id: ["can't be blank"],
               origin_id: ["can't be blank"],
               shipping_category_id: ["can't be blank"],
               shipping_methods: ["can't be blank"],
               state: ["can't be blank"]
             } = errors_on(cs)
    end
  end

  @update_params %{
    shipping_methods: [],
    tracking: %{id: "some_tracking_id"},
    state: "ready!",
    cost: Money.new(0, :USD),
    tax_total: Money.new(0, :USD),
    adjustment_total: Money.new(0, :USD),
    promo_total: Money.new(0, :USD),
    total: Money.new(0, :USD),
    origin_id: -1,
    order_id: -1,
    shipping_method_id: 1,
    shipping_category_id: -1,
    number: "WHAT",
    shipped_at: DateTime.utc_now()
  }

  @update_fields MapSet.new(
                   ~w(state shipped_at tracking)a ++
                     ~w(cost tax_total adjustment_total promo_total total)a ++
                     ~w(shipping_methods shipping_method_id)a
                 )

  describe "update_changeset/2" do
    test "fails with missing params" do
      assert cs = %{valid?: true} = Package.create_changeset(%Package{}, @params)
      package = apply_changes(cs)

      cs = Package.update_changeset(package, %{})
      refute cs.valid?

      assert %{
               adjustment_total: ["can't be blank"],
               cost: ["can't be blank"],
               promo_total: ["can't be blank"],
               shipping_method_id: ["can't be blank"],
               tax_total: ["can't be blank"],
               total: ["can't be blank"]
             } == errors_on(cs)
    end

    test "with valid params" do
      assert cs = %{valid?: true} = Package.create_changeset(%Package{}, @params)
      package = apply_changes(cs)

      assert cs = %{valid?: true} = Package.update_changeset(package, @update_params)

      assert cs.changes
             |> Map.keys()
             |> MapSet.new()
             |> MapSet.equal?(@update_fields)

      assert apply_changes(cs).shipping_methods == []
    end

    test "with invalid params" do
      assert cs = %{valid?: true} = Package.create_changeset(%Package{}, @params)
      package = apply_changes(cs)

      bad_params = %{
        shipping_methods: [1],
        tracking: 1
      }

      assert cs = %{valid?: false} = Package.update_changeset(package, bad_params)
      assert {"is invalid", [type: :map, validation: :cast]} = cs.errors[:tracking]

      assert {"is invalid", [type: {:array, :map}]} = cs.errors[:shipping_methods]
    end
  end
end
