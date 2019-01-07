defmodule Snitch.Domain.Calculator.FlatPercentTest do
  use ExUnit.Case
  use Snitch.DataCase
  import Snitch.Factory
  alias Snitch.Domain.Calculator.FlatPercent
  alias Snitch.Domain.Order

  describe "compute/2" do
    setup :zones
    setup :shipping_methods
    setup :embedded_shipping_methods

    test "with order", context do
      item_info = %{unit_price: Money.new!(currency(), 10), quantity: 3}

      calculator_params = %{percent_amount: 50}
      %{order: order} = setup_order(context, item_info)
      order_total = Order.total_amount(order)

      amount = FlatPercent.compute(order, calculator_params)

      assert amount ==
               order_total.amount
               |> Decimal.mult(calculator_params.percent_amount)
               |> Decimal.div(100)
    end

    test "with line_item", context do
      item_info = %{unit_price: Money.new!(currency(), 10), quantity: 3}

      calculator_params = %{percent_amount: 50}
      %{line_item: line_item} = setup_order(context, item_info)
      line_item_amount = Money.mult!(line_item.unit_price, line_item.quantity)

      amount = FlatPercent.compute(line_item, calculator_params)

      assert amount ==
               line_item_amount.amount
               |> Decimal.mult(calculator_params.percent_amount)
               |> Decimal.div(100)
    end
  end

  defp setup_order(context, item_info) do
    %{embedded_shipping_methods: embedded_shipping_methods} = context
    %{quantity: quantity, unit_price: unit_price} = item_info

    # setup stock for product
    stock_item = insert(:stock_item, count_on_hand: 100)
    shipping_category = insert(:shipping_category)

    # make order and it's packages
    product = stock_item.product
    order = insert(:order, state: "delivery")

    line_item =
      insert(:line_item,
        order: order,
        product: product,
        quantity: quantity,
        unit_price: unit_price
      )

    package =
      insert(:package,
        shipping_methods: embedded_shipping_methods,
        order: order,
        items: [],
        origin: stock_item.stock_location,
        shipping_category: shipping_category
      )

    package_item =
      insert(:package_item,
        quantity: quantity,
        product: product,
        line_item: line_item,
        package: package
      )

    %{order: order, line_item: line_item}
  end
end
