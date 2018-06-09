defmodule Snitch.Domain.Order.TransitionsTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase

  import Snitch.Factory

  alias Ecto.Multi
  alias BeepBop.Context
  alias Snitch.Data.Schema.{Address, Order}
  alias Snitch.Domain.Order.Transitions

  @patna %{
    first_name: "someone",
    last_name: "enoemos",
    address_line_1: "BR Ambedkar Chowk",
    address_line_2: "street",
    zip_code: "11111",
    city: "Rajendra Nagar",
    phone: "1234567890",
    country: nil,
    state: nil
  }

  setup :states

  describe "associate_address" do
    setup %{states: [%{country: country} = state]} do
      patna = %{@patna | country: country, state: state}

      [
        patna: patna,
        order: struct(insert(:order, user: build(:user)), line_items: [])
      ]
    end

    test "with valid params", %{patna: patna, order: order} do
      assert order.state == "cart"
      assert is_nil(order.billing_address_id) and is_nil(order.shipping_address_id)

      %Context{
        multi: multi
      } =
        result =
        order
        |> Context.new(state: %{billing_address: patna, shipping_address: patna})
        |> Transitions.associate_address()

      assert result.valid?
      assert [order: {:update, order_changeset, []}] = Ecto.Multi.to_list(multi)
      assert order_changeset.valid?
      updated_order = Repo.update!(order_changeset)

      # [states: [%{country: country} = state]] = states(%{})
      # patna = %{@patna | country: country, state: state}
      patna = %{patna | zip_code: "32145"}

      %Context{
        multi: multi
      } =
        result =
        updated_order
        |> Context.new(state: %{billing_address: patna, shipping_address: patna})
        |> Transitions.associate_address()

      assert result.valid?
      assert [order: {:update, order_changeset, []}] = Ecto.Multi.to_list(multi)
      assert order_changeset.valid?
      # IO.inspect order_changeset
      _twice_updated_order = Repo.update!(order_changeset)
    end
  end
end
