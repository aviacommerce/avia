defmodule Snitch.Domain.Order.TransitionsTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase

  import Snitch.Factory
  import Mox

  alias BeepBop.Context
  alias Ecto.Multi
  alias Snitch.Data.Schema.Order
  alias Snitch.Data.Schema.OrderAddress
  alias Snitch.Domain.Order.Transitions

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

  describe "associate_address" do
    setup %{states: [%{country: country} = state]} do
      patna = %{@patna | country_id: country.id, state_id: state.id}

      [
        patna: patna,
        order: struct(insert(:order, user: build(:user)))
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

      refute result.valid?

      assert {:error,
              %{
                valid?: false,
                changes: %{
                  shipping_address: %{
                    action: :insert,
                    valid?: false,
                    errors: [state_id: {"state is explicitly required for this country", _}]
                  }
                }
              }} = result.errors
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

      refute result.valid?
      assert [] = result.state.shipment
    end
  end

  describe "persist_shipment" do
    setup do
      [order: insert(:order, user: build(:user))]
    end

    test "when shipment is empty", %{order: order} do
      result =
        order
        |> Context.new(state: %{shipment: []})
        |> Transitions.persist_shipment()

      assert result.valid?
      assert [packages: {:run, _}] = Multi.to_list(result.multi)
      assert {:ok, %{packages: []}} = Repo.transaction(result.multi)
    end
  end

  describe "associate_package" do
    setup :shipping_categories
    setup :zones
    setup :shipping_methods_embedded

    @tag shipping_category_count: 1,
         shipping_method_count: 1,
         state_zone_count: 1
    setup context do
      expect(Snitch.Tools.DefaultsMock, :fetch, 3, fn :currency -> {:ok, :USD} end)
      order = insert(:order, user: build(:user))
      %{shipping_methods: [sm]} = context

      packages =
        insert_list(
          1,
          :package,
          order_id: order.id,
          origin: build(:stock_location),
          shipping_methods: [sm],
          shipping_category: build(:shipping_category)
        )

      [order: order, packages: packages]
    end

    test "with packages", %{order: order, packages: packages} do
      package = List.first(packages)
      selected_shipping_method = List.first(package.shipping_methods)

      shipping_methods = [
        %{package_id: package.id, shipping_method_id: selected_shipping_method.id}
      ]

      result =
        order
        |> Context.new(state: %{selected_shipping_methods: shipping_methods})
        |> Transitions.save_packages_methods()

      assert result.valid?
      assert [packages: {:run, _}] = Multi.to_list(result.multi)
      assert {:ok, %{packages: packages}} = Repo.transaction(result.multi)

      refute Enum.any?(packages, fn package ->
               with false <- is_nil(package.shipping_method_id),
                    false <- is_nil(package.tax_total),
                    false <- is_nil(package.promo_total),
                    false <- is_nil(package.adjustment_total),
                    do: false
             end)
    end
  end
end
