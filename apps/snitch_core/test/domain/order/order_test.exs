defmodule Snitch.Domain.OrderTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase

  import Mox
  import Snitch.Factory

  alias Snitch.Data.Schema.Order
  alias Snitch.Domain.Order, as: OrderDomain

  describe "add_line_item/2" do
    test "when order.state is `cart`" do
      assert {:ok, %Order{}} = OrderDomain.add_line_item(%Order{state: "cart"}, nil)
    end
  end

  describe "update_line_item/2" do
    test "when order.state is `cart`" do
      assert {:ok, %Order{}} = OrderDomain.update_line_item(%Order{state: "cart"}, nil)
    end
  end

  describe "remove_line_item/2" do
    test "when order.state is `cart`" do
      assert {:ok, %Order{}} = OrderDomain.remove_line_item(%Order{state: "cart"}, nil)
    end
  end

  describe "compute_taxes_changeset/1" do
    setup do
      [order: insert(:order, state: "foo")]
    end

    setup :variants
    setup :line_items

    test "for order in `cart`" do
      expect(Snitch.Tools.DefaultsMock, :fetch, 2, fn :currency -> {:ok, :USD} end)

      cs =
        %Order{state: "cart"}
        |> Order.partial_update_changeset(%{})
        |> OrderDomain.compute_taxes_changeset()

      assert cs.valid?

      assert cs.changes == %{
               item_total: Money.zero(:USD),
               tax_total: Money.zero(:USD),
               total: Money.zero(:USD)
             }
    end

    @tag variant_count: 1
    test "for order in with items", %{order: order, line_items: [item]} do
      expect(Snitch.Tools.DefaultsMock, :fetch, fn :currency -> {:ok, :USD} end)

      cs =
        order
        |> Order.partial_update_changeset(%{})
        |> OrderDomain.compute_taxes_changeset()

      total = Money.mult!(item.unit_price, item.quantity)

      assert %{
               item_total: total,
               total: total,
               tax_total: Money.zero(:USD)
             } == cs.changes

      assert cs.valid?
    end
  end
end
