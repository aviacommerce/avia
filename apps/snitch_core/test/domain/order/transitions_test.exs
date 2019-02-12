defmodule Snitch.Domain.Order.TransitionsTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase

  import Mox
  import Snitch.Factory

  alias BeepBop.Context
  alias Ecto.Multi
  alias Snitch.Data.Schema.{Order, OrderAddress}
  alias Snitch.Data.Schema.StockItem, as: StockItemSchema
  alias Snitch.Domain.Order.Transitions
  alias Snitch.Domain.Order, as: OrderDomain
  alias Snitch.Data.Model.Order, as: OrderModel

  @patna %{
    first_name: "someone",
    last_name: "enoemos",
    address_line_1: "BR Ambedkar Chowk",
    address_line_2: "street",
    zip_code: "11111",
    city: "Rajendra Nagar",
    phone: "1234567890",
    country_id: nil,
    state_id: nil
  }

  setup :states
  setup :verify_on_exit!

  describe "associate_address" do
    setup %{states: [%{country: country} = state]} do
      patna = %{@patna | country_id: country.id, state_id: state.id}

      [
        patna: patna,
        order: insert(:order)
      ]
    end

    test "fails with bad address", %{patna: patna, order: order} do
      result =
        order
        |> Context.new(
          state: %{
            billing_address: patna,
            shipping_address: %{patna | state_id: nil}
          }
        )
        |> Transitions.associate_address()

      assert result.valid?
      assert {:error, :order, cs, _} = Repo.transaction(result.multi)

      assert %{
               shipping_address: %{
                 state_id: ["state is explicitly required for this country"]
               }
             } == errors_on(cs)
    end

    test "with an order that has no addresses", %{patna: patna, order: order} do
      assert is_nil(order.billing_address) and is_nil(order.shipping_address)

      result =
        order
        |> Context.new(state: %{billing_address: patna, shipping_address: patna})
        |> Transitions.associate_address()

      assert result.valid?
    end

    test "with an order that already has addresses", %{patna: patna, order: order} do
      order =
        order
        |> Order.partial_update_changeset(%{billing_address: patna, shipping_address: patna})
        |> Repo.update!()

      state = insert(:state, country: nil, country_id: patna.country_id)
      not_patna = %{patna | state_id: state.id}

      result =
        order
        |> Context.new(state: %{billing_address: not_patna, shipping_address: not_patna})
        |> Transitions.associate_address()

      assert result.valid?
    end
  end

  describe "compute_shipments" do
    setup do
      shipping_address =
        :address
        |> build()
        |> Map.from_struct()
        |> Map.delete(:__meta__)

      [
        order:
          insert(
            :order,
            user: build(:user),
            shipping_address: Repo.load(OrderAddress, shipping_address)
          )
      ]
    end

    setup :variants
    setup :line_items

    @tag variant_count: 0
    test "of order with empty line items", %{order: order} do
      result =
        order
        |> Context.new()
        |> Transitions.compute_shipments()

      assert [] = result.state.shipment
    end

    @tag variant_count: 1
    test "of order with some out-of-stock variants", %{order: order} do
      result =
        order
        |> Context.new()
        |> Transitions.compute_shipments()

      assert result.valid?
      assert [] = result.state.shipment
    end
  end

  describe "persist_shipment" do
    setup :zones
    setup :shipping_methods
    setup :embedded_shipping_methods
    setup :states

    setup %{embedded_shipping_methods: methods, states: states} do
      order = order_with_tax_manifest(states)
      [order: order, packages: [insert(:package, shipping_methods: methods, order: order)]]
    end

    test "when shipment is empty", %{order: order} do
      result =
        order
        |> Context.new(state: %{shipment: []})
        |> Transitions.persist_shipment()

      assert result.valid?
      assert {:ok, []} = result.state.packages
    end

    @tag shipping_method_count: 1, state_count: 3
    test "fails when shipment is erroneous", %{order: order} do
      result =
        order
        |> Context.new(state: %{shipment: build_list(1, :shipment)})
        |> Transitions.persist_shipment()

      assert result.valid?
      assert {:error, _changeset} = result.state.packages
    end
  end

  describe "persist_shipping_preferences/1" do
    setup :zones
    setup :shipping_methods
    setup :embedded_shipping_methods
    setup :states

    setup %{embedded_shipping_methods: methods, states: states} do
      order = order_with_tax_manifest(states)
      [order: order, packages: [insert(:package, shipping_methods: methods, order: order)]]
    end

    @tag shipping_method_count: 1, state_count: 3
    test "with packages", %{order: order, packages: [package], shipping_methods: [sm]} do
      preference = [
        %{package_id: package.id, shipping_method_id: sm.id}
      ]

      result =
        order
        |> Context.new(state: %{shipping_preferences: preference})
        |> Transitions.persist_shipping_preferences()

      assert result.valid?
      assert [packages: {:run, _}] = Multi.to_list(result.multi)
      assert {:ok, %{packages: _}} = Repo.transaction(result.multi)
    end

    @tag shipping_method_count: 1, state_count: 3
    test "check order total after transition",
         %{
           shipping_methods: [sm],
           states: states
         } = context do
      set_cost = 20
      quantity = 3

      %{order: order, package: package, shipping_rule: shipping_rule} =
        setup_package_with_shipping(context, quantity, set_cost, states)

      preference = [
        %{package_id: package.id, shipping_method_id: sm.id}
      ]

      order_total = OrderDomain.total_amount(order)

      result =
        order
        |> Context.new(state: %{shipping_preferences: preference})
        |> Transitions.persist_shipping_preferences()

      assert {:ok, %{packages: _}} = Repo.transaction(result.multi)

      {:ok, order} = OrderModel.partial_update(order, %{state: :delivery})

      order = Repo.preload(order, [:packages, :line_items])
      line_item_total = OrderDomain.line_item_total(order)
      [package] = order.packages

      final_order_total =
        line_item_total
        |> Money.add!(package.cost)
        |> Money.add!(package.shipping_tax)
        |> Money.round()

      assert result.valid?

      assert final_order_total ==
               Money.add!(
                 order_total,
                 Money.new!(currency(), shipping_rule.preferences.cost)
               )
    end

    test "fails with invalid preferences", %{order: order} do
      result =
        order
        |> Context.new(state: %{shipping_preferences: []})
        |> Transitions.persist_shipping_preferences()

      refute result.valid?
      assert result.errors == [shipping_preferences: "is invalid"]
    end
  end

  test "persist_shipping_preferences/1 with empty packages" do
    result =
      :order
      |> insert(user: build(:user))
      |> Context.new(state: %{shipping_preferences: []})
      |> Transitions.persist_shipping_preferences()

    assert result.valid?
  end

  describe "update_stock/1" do
    setup :zones
    setup :shipping_methods
    setup :embedded_shipping_methods

    test "successful on making payment for order with right params",
         %{embedded_shipping_methods: methods} do
      stock_item_1 = insert(:stock_item, count_on_hand: 5)
      stock_item_2 = insert(:stock_item, count_on_hand: 5)

      product_1 = stock_item_1.product
      product_2 = stock_item_2.product

      order = insert(:order)
      line_item_1 = insert(:line_item, order: order, product: product_1, quantity: 2)
      line_item_2 = insert(:line_item, order: order, product: product_2, quantity: 2)

      package_1 =
        insert(:package,
          shipping_methods: methods,
          order: order,
          items: [],
          origin: stock_item_1.stock_location
        )

      package_2 =
        insert(:package,
          shipping_methods: methods,
          order: order,
          items: [],
          origin: stock_item_2.stock_location
        )

      package_item_1 =
        insert(:package_item,
          quantity: 2,
          product: product_1,
          line_item: line_item_1,
          package: package_1
        )

      package_item_2 =
        insert(:package_item,
          quantity: 2,
          product: product_2,
          line_item: line_item_2,
          package: package_2
        )

      result =
        order
        |> Context.new()
        |> Transitions.update_stock()

      assert result.valid?
      updated_stock_item_1 = Repo.get(StockItemSchema, stock_item_1.id)

      assert updated_stock_item_1.count_on_hand ==
               stock_item_1.count_on_hand - package_item_1.quantity

      updated_stock_item_2 = Repo.get(StockItemSchema, stock_item_2.id)

      assert updated_stock_item_2.count_on_hand ==
               stock_item_2.count_on_hand - package_item_2.quantity
    end

    test " fails on making payment for order with wrong package items",
         %{embedded_shipping_methods: methods} do
      stock_item = insert(:stock_item, count_on_hand: 5)

      product = stock_item.product

      order = insert(:order)
      line_item = insert(:line_item, order: order, product: product, quantity: 2)

      package =
        insert(:package,
          shipping_methods: methods,
          order: order,
          items: [],
          origin: stock_item.stock_location
        )

      insert(:package_item,
        quantity: 7,
        product: product,
        line_item: line_item,
        package: package
      )

      result =
        order
        |> Context.new()
        |> Transitions.update_stock()

      refute result.valid?
    end
  end

  defp order_with_tax_manifest(states) do
    order = insert(:order, shipping_address: address_manifest(List.first(states)))
    tax_class_values = %{shipping_tax: %{class: insert(:tax_class), percent: 5}}
    setup_tax_with_zone_and_rates(tax_class_values, states)

    order
  end

  defp setup_package_with_shipping(context, quantity, shipping_cost, states) do
    %{embedded_shipping_methods: embedded_shipping_methods} = context

    # setup stock for product
    stock_item = insert(:stock_item, count_on_hand: 10)

    # setup shipping category, identifier, rules
    shipping_identifier =
      insert(:shipping_identifier,
        code: :ofr,
        description: "fixed shipping rate for order"
      )

    shipping_category = insert(:shipping_category)

    shipping_rule =
      insert(:shipping_rule,
        active?: true,
        preferences: %{cost: shipping_cost},
        shipping_rule_identifier: shipping_identifier,
        shipping_category: shipping_category
      )

    # make order and it's packages
    product = stock_item.product

    order =
      insert(:order, state: :address, shipping_address: address_manifest(List.first(states)))

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

    %{order: order, package: package, shipping_rule: shipping_rule}
  end

  defp address_manifest(state) do
    %{
      first_name: "someone",
      last_name: "enoemos",
      address_line_1: "BR Ambedkar Chowk",
      address_line_2: "street",
      zip_code: "11111",
      city: "Rajendra Nagar",
      phone: "1234567890",
      country_id: state.country_id,
      state_id: state.id
    }
  end
end
