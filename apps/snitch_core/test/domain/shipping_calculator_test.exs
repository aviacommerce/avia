defmodule Snitch.Domain.ShippingCalculatorTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase

  import Mox
  import Snitch.Factory
  alias Snitch.Data.Schema.{Package, ShippingRule}
  alias Snitch.Domain.ShippingCalculator

  setup do
    Application.put_env(:snitch_core, :defaults, currency: :USD)
  end

  setup :zones
  setup :shipping_methods
  setup :embedded_shipping_methods

  describe "fixed rate per order :ofr" do
    test "returns only cost for :ofr", context do
      rule_active_manifest = %{fso: false, fsoa: false, ofr: true, fsrp: false}

      preference_manifest = %{
        fso: %{},
        fsoa: %{amount: 100},
        ofr: %{cost: 20},
        fsrp: %{cost_per_item: 5}
      }

      item_info = %{unit_price: Money.new!(currency(), 10), quantity: 5}

      %{package: package, category: category} = setup_package_with_sc(context, item_info)

      setup_shipping_rules(rule_active_manifest, preference_manifest, category)

      shipping_cost = ShippingCalculator.calculate(package)

      assert shipping_cost ==
               currency()
               |> Money.new!(preference_manifest.ofr.cost)
               |> Money.round()
    end

    test "with free for order above amount, returns 0 as :fsoa applies", context do
      rule_active_manifest = %{fso: false, fsoa: true, ofr: true, fsrp: false}

      preference_manifest = %{
        fso: %{},
        fsoa: %{amount: 50},
        ofr: %{cost: 20},
        fsrp: %{cost_per_item: 5}
      }

      item_info = %{unit_price: Money.new!(currency(), 10), quantity: 7}

      %{package: package, category: category} = setup_package_with_sc(context, item_info)

      setup_shipping_rules(rule_active_manifest, preference_manifest, category)

      shipping_cost = ShippingCalculator.calculate(package)

      # as order cost is above 50 USD shipping cost is 0
      # item_info.unit_price * item_info.quantity > preference_manifest.fsoa.amount
      assert shipping_cost ==
               currency()
               |> Money.new!(0)
               |> Money.round()
    end

    test "with free for order above amount :fsoa does not apply", context do
      rule_active_manifest = %{fso: false, fsoa: true, ofr: true, fsrp: false}

      preference_manifest = %{
        fso: %{},
        fsoa: %{amount: 200},
        ofr: %{cost: 20},
        fsrp: %{cost_per_item: 5}
      }

      item_info = %{unit_price: Money.new!(currency(), 10), quantity: 1}

      %{package: package, category: category} = setup_package_with_sc(context, item_info)

      setup_shipping_rules(rule_active_manifest, preference_manifest, category)

      shipping_cost = ShippingCalculator.calculate(package)

      # as free shipping is available over 200, fixed rate cost is applied
      # item_info.unit_price * item_info.quantity < preference_manifest.fsoa.amount
      assert shipping_cost ==
               currency()
               |> Money.new!(preference_manifest.ofr.cost)
               |> Money.round()
    end
  end

  describe "fixed rate per product" do
    test "returns only cost for :fsrp", context do
      rule_active_manifest = %{fso: false, fsoa: false, ofr: false, fsrp: true}

      preference_manifest = %{
        fso: %{},
        fsoa: %{amount: 100},
        ofr: %{cost: 20},
        fsrp: %{cost_per_item: 5}
      }

      item_info = %{unit_price: Money.new!(currency(), 10), quantity: 5}

      %{package: package, category: category} = setup_package_with_sc(context, item_info)

      setup_shipping_rules(rule_active_manifest, preference_manifest, category)

      shipping_cost = ShippingCalculator.calculate(package)

      # shipping cost at the rate of 5 per product is applied for 5 products
      # as no other rule is active.
      assert shipping_cost ==
               currency()
               |> Money.new!(preference_manifest.fsrp.cost_per_item)
               |> Money.mult!(item_info.quantity)
               |> Money.round()
    end

    test "with free for order above amount, returns 0 as :fsoa applies", context do
      rule_active_manifest = %{fso: false, fsoa: true, ofr: true, fsrp: true}

      preference_manifest = %{
        fso: %{},
        fsoa: %{amount: 50},
        ofr: %{cost: 20},
        fsrp: %{cost_per_item: 5}
      }

      item_info = %{unit_price: Money.new!(currency(), 10), quantity: 7}

      %{package: package, category: category} = setup_package_with_sc(context, item_info)

      setup_shipping_rules(rule_active_manifest, preference_manifest, category)

      shipping_cost = ShippingCalculator.calculate(package)

      # as order cost is above 50 USD shipping cost is 0
      assert shipping_cost == currency() |> Money.new!(0) |> Money.round()
    end

    test "with free for order above amount :fsoa does not apply", context do
      rule_active_manifest = %{fso: false, fsoa: true, ofr: false, fsrp: true}

      preference_manifest = %{
        fso: %{},
        fsoa: %{amount: 200},
        ofr: %{cost: 20},
        fsrp: %{cost_per_item: 5}
      }

      item_info = %{unit_price: Money.new!(currency(), 10), quantity: 1}

      %{package: package, category: category} = setup_package_with_sc(context, item_info)

      setup_shipping_rules(rule_active_manifest, preference_manifest, category)

      shipping_cost = ShippingCalculator.calculate(package)

      # as free shipping is available over 200, fixed rate  per product is applied
      assert shipping_cost ==
               currency()
               |> Money.new!(preference_manifest.fsrp.cost_per_item)
               |> Money.mult!(item_info.quantity)
               |> Money.round()
    end
  end

  test "for free shipping for all orders", context do
    rule_active_manifest = %{fso: true, fsoa: false, ofr: false, fsrp: false}

    preference_manifest = %{
      fso: %{},
      fsoa: %{amount: 200},
      ofr: %{cost: 20},
      fsrp: %{cost_per_item: 5}
    }

    item_info = %{unit_price: Money.new!(currency(), 10), quantity: 1}

    %{package: package, category: category} = setup_package_with_sc(context, item_info)

    setup_shipping_rules(rule_active_manifest, preference_manifest, category)

    shipping_cost = ShippingCalculator.calculate(package)

    # as free shipping is available over 200, fixed rate  per product is applied
    assert shipping_cost == Money.new!(currency(), 0) |> Money.round()
  end

  test "check for no rules set", context do
    item_info = %{unit_price: Money.new!(currency(), 10), quantity: 1}
    %{package: package, category: category} = setup_package_with_sc(context, item_info)

    shipping_cost = ShippingCalculator.calculate(package)

    # since no rules set cost is 0
    assert shipping_cost == Money.new!(currency(), 0) |> Money.round()
  end

  ############################# priavte functions #########################

  defp setup_shipping_rules(rule_active_manifest, preference_manifest, category) do
    %{
      ofr:
        shipping_rule(
          insert(:shipping_identifier, code: :ofr, description: "order fixed rate"),
          category,
          preference_manifest.ofr,
          rule_active_manifest.ofr
        ),
      fso:
        shipping_rule(
          insert(:shipping_identifier, code: :fso, description: "free shipping"),
          category,
          preference_manifest.fso,
          rule_active_manifest.fso
        ),
      fsrp:
        shipping_rule(
          insert(:shipping_identifier, code: :fsrp, description: "fixed shipping per product"),
          category,
          preference_manifest.fsrp,
          rule_active_manifest.fsrp
        ),
      fsoa:
        shipping_rule(
          insert(:shipping_identifier, code: :fsoa, description: "fixed shipping above amount"),
          category,
          preference_manifest.fsoa,
          rule_active_manifest.fsoa
        )
    }
  end

  defp shipping_rule(identifier, category, preferences, active_status) do
    sr =
      insert(:shipping_rule,
        active?: active_status,
        preferences: preferences,
        shipping_rule_identifier: identifier,
        shipping_category: category
      )
  end

  defp setup_package_with_sc(context, item_info) do
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

    package = Package |> Repo.get(package.id) |> Repo.preload(:items)
    %{package: package, category: shipping_category}
  end
end
