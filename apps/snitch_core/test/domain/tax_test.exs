defmodule Snitch.Domain.TaxTest do
  @moduledoc false

  use ExUnit.Case
  use Snitch.DataCase
  import Snitch.Factory
  alias Snitch.Domain.Tax

  setup :countries
  setup :states

  describe "caluclate/4 for package item" do
    setup do
      stock_item = insert(:stock_item, count_on_hand: 5)
      product = stock_item.product
      [tax_class: product.tax_class, product: product, stock_item: stock_item]
    end

    @tag state_count: 3
    test "tax address is shipping and, order has it set, tax included", context do
      zone = insert(:zone, zone_type: "S")
      %{tax_class: tax_class, product: product, states: states, stock_item: stock_item} = context
      [state_1, state_2, _] = states
      setup_state_zone_members(zone, states)
      shipping_address = address_manifest(:shipping, state_1)

      order_params = %{
        product: product,
        shipping_address: shipping_address,
        billing_address: nil,
        quantity_li: 2
      }

      %{order: order, line_item: line_item} = order_manifest(order_params)

      tax_params = %{
        zone: zone,
        address: :shipping_address,
        included: true,
        state: state_2,
        is_default: false
      }

      %{tax_zone: tax_zone} = tax_manifest(tax_params)
      tax_rate_params = %{tax_zone: tax_zone, value_manifest: [%{class: tax_class, percent: 5}]}
      tax_rate_manifest(tax_rate_params)

      assert %{original_amount: tax_less_amount, tax: tax} =
               Tax.calculate(:package_item, line_item, order, stock_item.stock_location)

      %{amount: calculated_amount, tax: tax_value} =
        included_tax_calculation(line_item.unit_price, 5, line_item.quantity)

      assert calculated_amount == tax_less_amount
      assert tax == tax_value
    end

    @tag state_count: 3
    test "tax address is shipping and, order has it set, tax excluded", context do
      zone = insert(:zone, zone_type: "S")
      %{tax_class: tax_class, product: product, states: states, stock_item: stock_item} = context
      [state_1, state_2, _] = states
      setup_state_zone_members(zone, states)
      shipping_address = address_manifest(:shipping, state_1)

      order_params = %{
        product: product,
        shipping_address: shipping_address,
        billing_address: nil,
        quantity_li: 2
      }

      %{order: order, line_item: line_item} = order_manifest(order_params)

      tax_params = %{
        zone: zone,
        address: :shipping_address,
        included: false,
        state: state_2,
        is_default: false
      }

      %{tax_zone: tax_zone} = tax_manifest(tax_params)
      tax_rate_params = %{tax_zone: tax_zone, value_manifest: [%{class: tax_class, percent: 5}]}
      tax_rate_manifest(tax_rate_params)

      assert %{original_amount: tax_less_amount, tax: tax} =
               Tax.calculate(:package_item, line_item, order, stock_item.stock_location)

      %{amount: calculated_amount, tax: tax_value} =
        excluded_tax_calculation(line_item.unit_price, 5, line_item.quantity)

      assert calculated_amount == tax_less_amount
      assert tax == tax_value
    end

    @tag state_count: 3
    test "tax address is shipping and, order does not has it set", context do
      zone = insert(:zone, zone_type: "S")
      %{tax_class: tax_class, product: product, states: states, stock_item: stock_item} = context
      [state_1, _, _] = states
      setup_state_zone_members(zone, states)

      order_params = %{
        product: product,
        shipping_address: nil,
        billing_address: nil,
        quantity_li: 2
      }

      %{order: order, line_item: line_item} = order_manifest(order_params)

      tax_params = %{
        zone: zone,
        address: :shipping_address,
        included: false,
        state: state_1,
        is_default: false
      }

      %{tax_zone: tax_zone} = tax_manifest(tax_params)
      tax_rate_params = %{tax_zone: tax_zone, value_manifest: [%{class: tax_class, percent: 5}]}
      tax_rate_manifest(tax_rate_params)

      assert %{original_amount: tax_less_amount, tax: tax} =
               Tax.calculate(:package_item, line_item, order, stock_item.stock_location)

      %{amount: calculated_amount, tax: tax_value} =
        excluded_tax_calculation(line_item.unit_price, 5, line_item.quantity)

      assert calculated_amount == tax_less_amount
      assert tax == tax_value
    end

    @tag state_count: 3
    test "tax address is billing and, order has it set", context do
      zone = insert(:zone, zone_type: "S")
      %{tax_class: tax_class, product: product, states: states, stock_item: stock_item} = context
      [state_1, state_2, _] = states
      setup_state_zone_members(zone, states)
      billing_address = address_manifest(:billing, state_1)

      order_params = %{
        product: product,
        shipping_address: nil,
        billing_address: billing_address,
        quantity_li: 2
      }

      %{order: order, line_item: line_item} = order_manifest(order_params)

      tax_params = %{
        zone: zone,
        address: :shipping_address,
        included: false,
        state: state_2,
        is_default: false
      }

      %{tax_zone: tax_zone} = tax_manifest(tax_params)
      tax_rate_params = %{tax_zone: tax_zone, value_manifest: [%{class: tax_class, percent: 5}]}
      tax_rate_manifest(tax_rate_params)

      assert %{original_amount: tax_less_amount, tax: tax} =
               Tax.calculate(:package_item, line_item, order, stock_item.stock_location)

      %{amount: calculated_amount, tax: tax_value} =
        excluded_tax_calculation(line_item.unit_price, 5, line_item.quantity)

      assert calculated_amount == tax_less_amount
      assert tax == tax_value
    end

    @tag state_count: 3
    test "tax is 0 if, zone is set but no tax rates are set", context do
      zone = insert(:zone, zone_type: "S")
      %{tax_class: tax_class, product: product, states: states, stock_item: stock_item} = context
      [state_1, state_2, _] = states
      setup_state_zone_members(zone, states)
      billing_address = address_manifest(:billing, state_1)

      order_params = %{
        product: product,
        shipping_address: nil,
        billing_address: billing_address,
        quantity_li: 2
      }

      %{order: order, line_item: line_item} = order_manifest(order_params)

      tax_params = %{
        zone: zone,
        address: :shipping_address,
        included: false,
        state: state_2,
        is_default: false
      }

      tax_manifest(tax_params)

      assert %{original_amount: tax_less_amount, tax: tax} =
               Tax.calculate(:package_item, line_item, order, stock_item.stock_location)

      %{amount: calculated_amount, tax: tax_value} =
        excluded_tax_calculation(line_item.unit_price, 5, line_item.quantity)

      assert calculated_amount == tax_less_amount
      assert tax == Money.new!(currency, 0)
    end

    @tag state_count: 1
    test "default zone used if, tax zone not found for order address", context do
      zone = insert(:zone, zone_type: "S")
      %{tax_class: tax_class, product: product, states: states, stock_item: stock_item} = context
      [state] = states
      setup_state_zone_members(zone, states)
      billing_address = address_manifest(:billing, insert(:state))

      order_params = %{
        product: product,
        shipping_address: nil,
        billing_address: billing_address,
        quantity_li: 2
      }

      %{order: order, line_item: line_item} = order_manifest(order_params)

      tax_params = %{
        zone: zone,
        address: :billing_address,
        included: false,
        state: state,
        is_default: true
      }

      %{tax_zone: tax_zone} = tax_manifest(tax_params)
      tax_rate_params = %{tax_zone: tax_zone, value_manifest: [%{class: tax_class, percent: 5}]}
      tax_rate_manifest(tax_rate_params)

      assert %{original_amount: tax_less_amount, tax: tax} =
               Tax.calculate(:package_item, line_item, order, stock_item.stock_location)

      %{amount: _calculated_amount, tax: tax_value} =
        excluded_tax_calculation(line_item.unit_price, 5, line_item.quantity)

      assert tax_less_amount == line_item.unit_price
      assert tax == tax_value
    end
  end

  describe "calculate/4 shipping" do
    @tag state_count: 3
    test "tax 0 if tax rate does not have shipping class value set", context do
      zone = insert(:zone, zone_type: "S")
      %{states: states} = context
      [state_1, _, _] = states
      setup_state_zone_members(zone, states)
      shipping_address = address_manifest(:shipping, List.first(states))

      order = insert(:order, shipping_address: shipping_address)

      stock_location =
        insert(:stock_location,
          state: state_1,
          country: state_1.country
        )

      tax_class = insert(:tax_class)

      tax_params = %{
        zone: zone,
        address: :shipping_address,
        included: false,
        state: state_1,
        is_default: false
      }

      %{tax_zone: tax_zone} = tax_manifest(tax_params)
      tax_rate_params = %{tax_zone: tax_zone, value_manifest: [%{class: tax_class, percent: 5}]}
      tax_rate_manifest(tax_rate_params)

      shipping_cost = Money.new!(:USD, 10)

      assert %{original_amount: amount, tax: tax} =
               Tax.calculate(:shipping, shipping_cost, order, stock_location)

      assert amount == shipping_cost
      assert tax == Money.new!(:USD, 0)
    end

    @tag state_count: 3
    test "tax 0 if no tax rates are set for tax zone", context do
      zone = insert(:zone, zone_type: "S")
      %{states: states} = context
      [state_1, _, _] = states
      setup_state_zone_members(zone, states)
      shipping_address = address_manifest(:shipping, List.first(states))

      order = insert(:order, shipping_address: shipping_address)

      stock_location =
        insert(:stock_location,
          state: state_1,
          country: state_1.country
        )

      tax_class = insert(:tax_class)

      tax_params = %{
        zone: zone,
        address: :shipping_address,
        included: false,
        state: state_1,
        is_default: false
      }

      tax_manifest(tax_params)

      shipping_cost = Money.new!(:USD, 10)

      assert %{original_amount: amount, tax: tax} =
               Tax.calculate(:shipping, shipping_cost, order, stock_location)

      assert amount == shipping_cost
      assert tax == Money.new!(:USD, 0)
    end

    @tag state_count: 3
    test "default zone used if, tax zone not found for address", context do
      zone = insert(:zone, zone_type: "S")
      %{states: states} = context
      [state_1, _, _] = states
      setup_state_zone_members(zone, states)
      shipping_address = address_manifest(:shipping, insert(:state))

      order = insert(:order, shipping_address: shipping_address)

      stock_location =
        insert(:stock_location,
          state: state_1,
          country: state_1.country
        )

      tax_class = insert(:tax_class)

      insert(:tax_config,
        default_state: state_1,
        default_country: state_1.country,
        calculation_address_type: :shipping_address,
        included_in_price?: false,
        shipping_tax: tax_class
      )

      tax_zone = insert(:tax_zone, zone: zone, zone_id: zone.id, is_default: true)

      tax_rate_params = %{tax_zone: tax_zone, value_manifest: [%{class: tax_class, percent: 5}]}
      tax_rate_manifest(tax_rate_params)

      shipping_cost = Money.new!(:USD, 10)

      assert %{original_amount: amount, tax: tax} =
               Tax.calculate(:shipping, shipping_cost, order, stock_location)

      %{amount: calculated_amount, tax: tax_value} = excluded_tax_calculation(shipping_cost, 5, 1)

      assert amount == calculated_amount
      assert tax == tax_value
    end
  end

  defp order_manifest(params) do
    order =
      insert(:order,
        shipping_address: params.shipping_address,
        billing_address: params.billing_address
      )

    line_item =
      insert(:line_item, order: order, product: params.product, quantity: params.quantity_li)

    %{order: order, line_item: line_item}
  end

  defp tax_manifest(params) do
    tax_config =
      insert(:tax_config,
        default_state: params.state,
        default_country: params.state.country,
        calculation_address_type: params.address,
        included_in_price?: params.included
      )

    tax_zone =
      insert(:tax_zone, zone: params.zone, zone_id: params.zone.id, is_default: params.is_default)

    %{tax_zone: tax_zone, tax_config: tax_config}
  end

  defp tax_rate_manifest(params) do
    tax_rate = insert(:tax_rate, tax_zone: params.tax_zone)

    values = params.value_manifest

    Enum.map(values, fn %{class: class, percent: percent} ->
      insert(:tax_rate_class_value, tax_rate: tax_rate, tax_class: class, percent_amount: percent)
    end)
  end

  defp setup_state_zone_members(zone, states) do
    Enum.each(states, fn state ->
      insert(:state_zone_member, zone: zone, state: state)
    end)
  end

  defp setup_country_zone_members(zone, countries) do
    Enum.each(countries, fn country ->
      insert(:country_zone_member, zone: zone, country: country)
    end)
  end

  defp address_manifest(:shipping, state) do
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

  defp address_manifest(:billing, state) do
    address_manifest(:shipping, state)
  end

  defp included_tax_calculation(amount, tax_percent, quantity) do
    offset =
      amount
      |> Money.mult!(100)
      |> Money.div!(100 + tax_percent)
      |> Money.round(currency_digits: :cash)

    tax_value = amount |> Money.sub!(offset) |> Money.mult!(quantity)
    %{amount: offset, tax: tax_value}
  end

  defp excluded_tax_calculation(amount, tax_percent, quantity) do
    tax_value =
      amount
      |> Money.mult!(tax_percent)
      |> Money.div!(100)
      |> Money.round(currency_digits: :cash)
      |> Money.mult!(quantity)

    %{amount: amount, tax: tax_value}
  end
end
