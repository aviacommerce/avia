defmodule Snitch.Data.Schema.LineItemTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase

  import Snitch.Factory

  alias Ecto.Changeset
  alias Snitch.Data.Schema.LineItem
  alias Snitch.Data.Model.LineItem, as: LineItemModel

  @params %{
    order_id: nil,
    variant_id: nil,
    quantity: 1,
    unit_price: nil,
    total: nil
  }

  setup :variants

  setup do
    user = insert(:user)

    [
      user: user,
      order: insert(:order, user_id: user.id)
    ]
  end

  describe "create_changeset/2" do
    test "fails with empty params" do
      cs = LineItem.create_changeset(%LineItem{}, %{})

      assert %{
               order_id: ["can't be blank"],
               quantity: ["can't be blank"],
               total: ["can't be blank"],
               unit_price: ["can't be blank"],
               variant_id: ["can't be blank"]
             } = errors_on(cs)
    end

    test "fails without price fields", %{order: order, variants: [variant | _]} do
      cs =
        LineItem.create_changeset(%LineItem{}, %{
          @params
          | variant_id: variant.id,
            order_id: order.id
        })

      assert %{
               total: ["can't be blank"],
               unit_price: ["can't be blank"]
             } = errors_on(cs)
    end

    test "fails with bad price fields", %{order: order, variants: [variant | _]} do
      cs =
        LineItem.create_changeset(%LineItem{}, %{
          @params
          | variant_id: variant.id,
            order_id: order.id,
            unit_price: Money.new(-1, :USD),
            total: Money.new(-2, :USD)
        })

      assert %{
               total: ["must be equal or greater than 0"],
               unit_price: ["must be equal or greater than 0"]
             } = errors_on(cs)
    end

    test "with price fields", %{order: order, variants: [variant | _]} do
      cs =
        LineItem.create_changeset(%LineItem{}, %{
          @params
          | variant_id: variant.id,
            order_id: order.id,
            unit_price: Money.new(0, :USD),
            total: Money.new(0, :USD)
        })

      assert cs.valid?

      [params_with_price] =
        LineItemModel.update_price_and_totals([
          %{@params | variant_id: variant.id, order_id: order.id}
        ])

      cs = LineItem.create_changeset(%LineItem{}, params_with_price)
      assert cs.valid?
    end
  end

  describe "update_changeset/2" do
    setup %{order: order, variants: [variant | _]} do
      cs =
        LineItem.create_changeset(%LineItem{}, %{
          @params
          | variant_id: variant.id,
            order_id: order.id,
            unit_price: Money.new(2, :USD),
            total: Money.new(2, :USD)
        })

      [line_item: Changeset.apply_changes(cs)]
    end

    test "fails with only quantity", %{line_item: line_item} do
      cs = LineItem.update_changeset(line_item, %{quantity: line_item.quantity + 1})
      refute cs.valid?
      assert %{total: ["can't be blank"]} = errors_on(cs)
    end

    test "fails with only unit_price", %{line_item: line_item} do
      cs =
        LineItem.update_changeset(line_item, %{unit_price: Money.mult!(line_item.unit_price, 2)})

      refute cs.valid?
      assert %{total: ["can't be blank"]} = errors_on(cs)
    end

    test "with empty params", %{line_item: line_item} do
      cs = LineItem.update_changeset(line_item, %{})
      assert cs.valid?
    end

    test "with valid params", %{line_item: line_item} do
      cs =
        LineItem.update_changeset(line_item, %{
          @params
          | variant_id: 1,
            unit_price: Money.new(2, :USD),
            total: Money.new(2, :USD)
        })

      assert cs.valid?
      refute Map.has_key?(cs.changes, :variant_id)
    end
  end
end
