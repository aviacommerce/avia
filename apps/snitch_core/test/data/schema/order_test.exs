defmodule Snitch.Data.Schema.OrderTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase

  import Snitch.Factory

  alias Snitch.Data.Model.LineItem
  alias Snitch.Data.Schema.Order

  @address_params %{
    first_name: "Tony",
    last_name: "Stark",
    address_line_1: "10-8-80 Malibu Point",
    zip_code: "90265",
    city: "Malibu",
    phone: "1234567890",
    state: nil,
    state_id: nil,
    country: nil,
    country_id: nil
  }

  @order_params %{
    adjustment_total: nil,
    promo_total: nil,
    item_total: nil,
    total: nil,
    line_items: nil,
    user_id: nil
  }

  setup :variants
  setup :user_with_address

  test "both order and line_items are inserted to DB", context do
    %{user: user, variants: variants} = context
    line_items = line_item_params(variants)
    item_total = total(line_items)

    params = %{
      @order_params
      | item_total: item_total,
        total: item_total,
        user_id: user.id,
        line_items: line_items
    }

    cs = Order.create_changeset(build(:order), params)

    %{
      valid?: validity,
      changes: %{
        item_total: _,
        total: _,
        line_items: _line_item_changesets
      }
    } = cs

    assert validity
    assert cs.changes.item_total == item_total
    assert cs.changes.total == item_total
    assert {:ok, _} = Repo.insert(cs)
  end

  test "order can handle duplicate line_items", %{user: user, variants: [v | _]} do
    params = %{
      @order_params
      | user_id: user.id,
        line_items: line_item_params([v, v])
    }

    cs = Order.create_changeset(build(:order), params)

    %{
      valid?: validity,
      changes: %{
        line_items: line_item_changesets
      }
    } = cs

    refute validity
    assert Enum.all?(line_item_changesets, fn %{valid?: validity} -> validity end)
    assert %{line_items: ["line_items must have unique variant_ids"]} = errors_on(cs)
  end

  test "order can be created without line_items", %{user: user} do
    params = %{
      @order_params
      | user_id: user.id,
        line_items: []
    }

    cs = Order.create_changeset(build(:order), params)
    assert cs.valid?
  end

  describe "order updates" do
    setup %{user: user, variants: variants} do
      line_items = line_item_params(variants)
      item_total = total(line_items)

      params = %{
        @order_params
        | user_id: user.id,
          line_items: line_items,
          item_total: item_total,
          total: item_total,
          promo_total: Money.zero(:USD),
          adjustment_total: Money.zero(:USD)
      }

      [
        persisted:
          :order
          |> build()
          |> Order.create_changeset(params)
          |> Repo.insert!()
      ]
    end

    test "unassociated line_items", context do
      %{persisted: persisted, variants: variants} = context
      params = %{line_items: line_item_params(variants)}
      cs = Order.update_changeset(persisted, params)

      %{valid?: validity, changes: changes} = cs

      assert validity
      # 3 old LIs replaced (aka deleted) and 3 new inserted.
      assert Enum.all?(changes.line_items, fn x -> x.action in [:insert, :replace] end)
      assert {:ok, order} = Repo.update(cs)
      assert order.total == persisted.total
      assert order.item_total == persisted.item_total
    end

    test "quantity, variant", context do
      %{persisted: persisted} = context
      [one, two, three] = persisted.line_items

      line_items =
        LineItem.update_price_and_totals([
          %{id: two.id, variant_id: two.variant_id, quantity: 9},
          %{id: one.id, variant_id: three.variant_id, quantity: one.quantity},
          %{id: three.id, variant_id: one.variant_id, quantity: three.quantity}
        ])

      item_total = total(line_items)

      params = %{
        line_items: line_items,
        item_total: item_total,
        total: item_total
      }

      cs = Order.update_changeset(persisted, params)
      %{valid?: validity, changes: changes} = cs

      assert validity
      assert Enum.all?(changes.line_items, fn x -> x.action == :update end)
      assert {:ok, order} = Repo.update(cs)
      assert order.item_total == item_total
      assert order.total == item_total
    end

    test "no changes, bud!", context do
      %{persisted: persisted} = context
      [one, two, three] = persisted.line_items

      line_items =
        LineItem.update_price_and_totals([%{id: one.id}, %{id: two.id}, %{id: three.id}])

      item_total = total(persisted.line_items)

      params = %{
        line_items: line_items,
        item_total: item_total,
        total: item_total
      }

      cs = Order.update_changeset(persisted, params)

      %{valid?: validity, changes: changes} = cs
      assert validity
      assert changes == %{}
      assert {:ok, order} = Repo.update(cs)
      assert order.item_total == persisted.item_total
      assert order.total == persisted.total
    end
  end

  describe "partial_update_changeset" do
    setup %{user: u} do
      [persisted: insert(:order, user: u, shipping_address: nil, billing_address: nil)]
    end

    test "fails with bad address params", %{persisted: persisted, address: address} do
      address_params = %{
        @address_params
        | country_id: address.country.id,
          state_id: -1
      }

      params = %{
        shipping_address: address_params,
        billing_address: address_params
      }

      cs = Order.partial_update_changeset(persisted, params)
      refute cs.valid?

      assert %{
               shipping_address: %{state_id: ["does not exist"]},
               billing_address: %{state_id: ["does not exist"]}
             } = errors_on(cs)
    end

    test "with valid address params", %{persisted: persisted, address: address} do
      address_params = %{
        @address_params
        | country_id: address.country.id,
          state_id: address.state.id
      }

      params = %{
        shipping_address: address_params,
        billing_address: address_params,
        promo_total: Money.zero(:INR)
      }

      cs = Order.partial_update_changeset(persisted, params)
      assert cs.valid?
      assert {:ok, Money.zero(:INR)} == Map.fetch(cs.changes, :promo_total)
      assert {:ok, _} = Repo.update(cs)
    end
  end

  defp line_item_params([]), do: []

  defp line_item_params(variants) do
    line_items =
      variants
      |> Stream.map(fn x -> x.id end)
      |> Enum.into([], fn variant_id ->
        %{variant_id: variant_id, quantity: 2}
      end)

    LineItem.update_price_and_totals(line_items)
  end

  defp total(line_items) do
    line_items
    |> Stream.map(&Map.fetch!(&1, :total))
    |> Enum.reduce(&Money.add!/2)
  end
end

defmodule Snitch.Data.Schema.OrderDocTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase

  import Snitch.Factory

  setup do
    insert(:variant)
    :ok
  end

  doctest Snitch.Data.Schema.Order
end
