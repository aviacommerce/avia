defmodule Snitch.Domain.OrderTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase

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
end
