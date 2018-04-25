defmodule Snitch.Domain.Order.TransitionsTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase

  import Snitch.Factory

  alias BeepBop.Context
  alias Ecto.Multi
  alias Snitch.Data.Schema.Order
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

      assert %{
               valid?: false,
               changes: %{
                 shipping_address: %{
                   action: :insert,
                   valid?: false,
                   errors: [state_id: {"state is explicitly required for this country", _}]
                 }
               }
             } = result.multi
    end

    test "with an order that has no addresses", %{patna: patna, order: order} do
      assert is_nil(order.billing_address_id) and is_nil(order.shipping_address_id)

      result =
        order
        |> Context.new(state: %{billing_address: patna, shipping_address: patna})
        |> Transitions.associate_address()

      assert result.valid?
    end

    test "with an order that already has addresses", %{patna: patna, order: order} do
      order =
        order
        |> Repo.preload([:shipping_address, :billing_address])
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
      [
        order:
          insert(
            :order,
            user: build(:user),
            shipping_address: build(:address)
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
end
