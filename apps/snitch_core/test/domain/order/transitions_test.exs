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

  describe "persist_shipping_preferences/1" do
    setup :zones
    setup :shipping_methods
    setup :embedded_shipping_methods

    setup %{embedded_shipping_methods: methods} do
      order = insert(:order, user: build(:user))

      [order: order, packages: [insert(:package, shipping_methods: methods, order: order)]]
    end

    @tag shipping_method_count: 1
    test "with packages", %{order: order, packages: [package], shipping_methods: [sm]} do
      preference = [
        %{package_id: package.id, shipping_method_id: sm.id}
      ]

      expect(Snitch.Tools.DefaultsMock, :fetch, fn :currency -> {:ok, :USD} end)

      result =
        order
        |> Context.new(state: %{shipping_preferences: preference})
        |> Transitions.persist_shipping_preferences()

      assert result.valid?
      assert [packages: {:run, _}] = Multi.to_list(result.multi)
      assert {:ok, %{packages: _}} = Repo.transaction(result.multi)
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
end
