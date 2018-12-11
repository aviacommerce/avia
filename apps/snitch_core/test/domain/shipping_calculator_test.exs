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

    test "check for `free for order above some amount`", context do
      expect(Snitch.Tools.DefaultsMock, :fetch, 3, fn :currency -> {:ok, :USD} end)
      rule_active_manifest = [true, false, true, false]
      cost_manifest = [Money.new!(:USD, 0), Money.new!(:USD, 100), Money.new!(:USD, 10)]

      # set 12 items so total cost is greater than lower_limit of 100
      package = setup_package_with_shipping(context, 12, cost_manifest, rule_active_manifest)

      shipping_cost = ShippingCalculator.calculate(package)

      # as order cost is above 100 USD shipping cost is 0
      assert shipping_cost == Money.new!(:USD, 0) |> Money.round()
    end

    test "check for `fixed cost per order`", context do
      expect(Snitch.Tools.DefaultsMock, :fetch, 3, fn :currency -> {:ok, :USD} end)
      # order rule is set to false so it won't override product rule

      rule_active_manifest = [true, false, true, false]
      cost_manifest = [Money.new!(:USD, 100), Money.new!(:USD, 100), Money.new!(:USD, 10)]

      package = setup_package_with_shipping(context, 3, cost_manifest, rule_active_manifest)

      shipping_cost = ShippingCalculator.calculate(package)

      # since total order cost would be less fixed rate for order is
      # applied
      assert shipping_cost == Money.new!(:USD, 10) |> Money.round()
    end

    test "check for 'free for order", context do
      expect(Snitch.Tools.DefaultsMock, :fetch, 3, fn :currency -> {:ok, :USD} end)
      # order rule is set to false so it won't override product rule

      # all rules set to true but they are overridden by free shipping for order
      rule_active_manifest = [true, true, true, true]
      cost_manifest = [Money.new!(:USD, 100), Money.new!(:USD, 100), Money.new!(:USD, 10)]

      package = setup_package_with_shipping(context, 3, cost_manifest, rule_active_manifest)

      shipping_cost = ShippingCalculator.calculate(package)

      # since free shipping for order is set cost is 0
      assert shipping_cost == Money.new!(:USD, 0) |> Money.round()
    end

    test "check for 'fixed rate for each product'", context do
      expect(Snitch.Tools.DefaultsMock, :fetch, 3, fn :currency -> {:ok, :USD} end)
      # order rule is set to false so it won't override product rule

      rule_active_manifest = [false, true, false, false]
      cost_manifest = [Money.new!(:USD, 100), Money.new!(:USD, 10), Money.new!(:USD, 10)]

      package = setup_package_with_shipping(context, 3, cost_manifest, rule_active_manifest)

      shipping_cost = ShippingCalculator.calculate(package)

      # fixed cost per product so, total cost is USD 10 X 3
      assert shipping_cost == Money.mult!(Money.new!(:USD, 10), 3) |> Money.round()
    end

    test "check for no rules set", context do
      expect(Snitch.Tools.DefaultsMock, :fetch, 3, fn :currency -> {:ok, :USD} end)
      # order rule is set to false so it won't override product rule

      rule_active_manifest = [false, false, false, false]
      cost_manifest = [Money.new!(:USD, 100), Money.new!(:USD, 10), Money.new!(:USD, 10)]

      package = setup_package_with_shipping(context, 3, cost_manifest, rule_active_manifest)

      shipping_cost = ShippingCalculator.calculate(package)

      # cost is 0 if nothing set
      assert shipping_cost == Money.new!(:USD, 0) |> Money.round()
    end
  end

  defp setup_package_with_shipping(context, quantity, cost_manifest, status_mannifest) do
    %{embedded_shipping_methods: embedded_shipping_methods} = context

    # setup stock for product
    stock_item = insert(:stock_item, count_on_hand: 20)

    # setup shipping category, identifier, rules
    shipping_identifier_1 = insert(:shipping_identifier)
    shipping_identifier_2 = insert(:shipping_identifier, code: :fsrp)
    shipping_identifier_3 = insert(:shipping_identifier, code: :fiso)
    shipping_identifier_4 = insert(:shipping_identifier, code: :fso)
    [cost1, cost2, cost3] = cost_manifest
    [status_1, status_2, status_3, status_4] = status_mannifest

    shipping_category = insert(:shipping_category)

    shipping_rule_1 =
      insert(:shipping_rule,
        active?: status_1,
        shipping_cost: cost1,
        shipping_rule_identifier: shipping_identifier_1,
        shipping_category: shipping_category
      )

    shipping_rule_2 =
      insert(:shipping_rule,
        active?: status_2,
        shipping_cost: cost2,
        shipping_rule_identifier: shipping_identifier_2,
        shipping_category: shipping_category
      )

    shipping_rule_3 =
      insert(:shipping_rule,
        active?: status_3,
        shipping_cost: cost3,
        shipping_rule_identifier: shipping_identifier_3,
        shipping_category: shipping_category
      )

    shipping_rule_4 =
      insert(:shipping_rule,
        active?: status_4,
        shipping_rule_identifier: shipping_identifier_4,
        shipping_category: shipping_category
      )

    # make order and it's packages
    product = stock_item.product
    order = insert(:order, state: :delivery)
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
