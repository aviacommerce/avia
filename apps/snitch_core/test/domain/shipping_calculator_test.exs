defmodule Snitch.Domain.ShippingCalculatorTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase

  import Mox
  import Snitch.Factory
  alias Snitch.Data.Schema.Package
  alias Snitch.Domain.ShippingCalculator

  setup do
    Application.put_env(:snitch_core, :defaults, currency: :USD)
  end

  describe "calculate/1" do
    setup :zones
    setup :shipping_methods
    setup :embedded_shipping_methods

    test "with active rule `free for order above some amount`", context do
      expect(Snitch.Tools.DefaultsMock, :fetch, 3, fn :currency -> {:ok, :USD} end)
      rule_active_manifest = [true, true]
      set_cost = Money.new!(:USD, 0)

      # set 12 items so total cost is greater than lower_limit of 100
      package = setup_package_with_shipping(context, 12, set_cost, rule_active_manifest)

      shipping_cost = ShippingCalculator.calculate(package)
      assert shipping_cost == set_cost
    end

    test "with active rule `fixed cost per product`", context do
      expect(Snitch.Tools.DefaultsMock, :fetch, 3, fn :currency -> {:ok, :USD} end)
      # order rule is set to false so it won't override product rule
      rule_active_manifest = [false, true]
      quantity = 3

      set_cost =
        :USD
        |> Money.new!(10)
        |> Money.round()

      package = setup_package_with_shipping(context, 3, set_cost, rule_active_manifest)

      shipping_cost = ShippingCalculator.calculate(package)
      assert shipping_cost == Money.mult!(set_cost, quantity)
    end
  end

  defp setup_package_with_shipping(context, quantity, shipping_cost, [status_1, status_2]) do
    %{embedded_shipping_methods: embedded_shipping_methods} = context

    # setup stock for product
    stock_item = insert(:stock_item, count_on_hand: 20)

    # setup shipping category, identifier, rules
    shipping_identifier_1 = insert(:shipping_identifier)
    shipping_identifier_2 = insert(:shipping_identifier, code: :fsrp)

    shipping_category = insert(:shipping_category)

    shipping_rule_1 =
      insert(:shipping_rule,
        lower_limit: 100,
        active?: status_1,
        shipping_cost: shipping_cost,
        shipping_rule_identifier: shipping_identifier_1,
        shipping_category: shipping_category
      )

    shipping_rule_2 =
      insert(:shipping_rule,
        active?: status_2,
        shipping_cost: shipping_cost,
        shipping_rule_identifier: shipping_identifier_2,
        shipping_category: shipping_category
      )

    # make order and it's packages
    product = stock_item.product
    order = insert(:order, state: "delivery")
    line_item = insert(:line_item, order: order, product: product, quantity: quantity)

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

    package = Repo.get(Package, package.id)
  end
end
