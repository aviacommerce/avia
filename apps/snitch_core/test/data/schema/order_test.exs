defmodule Snitch.Schema.OrderTest do
  use ExUnit.Case, async: true
  alias Snitch.Data.Schema
  import Snitch.Factory
  alias Snitch.Data.Model

  setup :checkout_repo
  setup :three_variants
  setup :user_with_address

  describe "order totals are updated and line_items are inserted to DB" do
    setup [:good_line_items, :order_changeset]

    test "", context do
      %{order: order} = context
      %{valid?: validity, changes: changes} = order
      assert validity
      assert Map.has_key?(changes, :item_total)
      assert Enum.all?(changes.line_items, fn %{action: action} -> action == :insert end)
      # check DB level constraints too
      assert {:ok, _} = Snitch.Repo.insert(order)
    end
  end

  describe "order can handle duplicate line_items" do
    setup [:duplicate_line_items, :order_changeset]

    test "", context do
      %{order: order} = context
      %{valid?: validity, changes: changes, errors: [error]} = order
      refute validity
      refute Map.has_key?(changes, :item_total)
      assert Enum.all?(changes.line_items, fn %{valid?: validity} -> validity end)
      assert error == {:duplicate_variants, {"line_items must have unique variant_ids", []}}
    end
  end

  describe "order cannot be created without line_items" do
    setup [:order_changeset]

    test "", context do
      %{order: order} = context
      %{valid?: validity, errors: [error]} = order
      refute validity
      assert error == {:line_items, {"can't be blank", [validation: :required]}}
    end
  end

  describe "order updates" do
    setup [:good_line_items, :order_changeset, :persist]

    test "unassociated line_items", context do
      %{persisted: persisted, line_items: line_items} = context
      params = %{line_items: Model.LineItem.update_price_and_totals(line_items)}
      new_order = Schema.Order.changeset(persisted, params, :update)
      %{valid?: validity, changes: changes} = new_order

      assert validity
      assert {:ok, _} = Snitch.Repo.update(new_order)
      assert Enum.all?(changes.line_items, fn x -> x.action in [:insert, :replace] end)
    end

    test "quantity, variant", context do
      %{persisted: persisted} = context
      [one, two, three] = persisted.line_items

      new_line_items = [
        %{id: two.id, variant_id: two.variant_id, quantity: 9},
        %{id: one.id, variant_id: three.variant_id, quantity: one.quantity},
        %{id: three.id, variant_id: one.variant_id, quantity: three.quantity}
      ]

      totals = [
        Money.mult!(two.unit_price, 9),
        Money.mult!(three.unit_price, one.quantity),
        Money.mult!(one.unit_price, three.quantity)
      ]

      total = Enum.reduce(totals, &Money.add!/2)
      params = %{line_items: Model.LineItem.update_price_and_totals(new_line_items)}

      new_order = Schema.Order.changeset(persisted, params, :update)
      %{valid?: validity, changes: changes} = new_order

      assert validity
      assert {:ok, _} = Snitch.Repo.update(new_order)
      assert Map.fetch!(changes, :item_total) == Money.reduce(total)
      assert Enum.all?(changes.line_items, fn x -> x.action == :update end)
    end

    test "no changes, bud!", context do
      %{persisted: persisted} = context
      [one, two, three] = persisted.line_items
      new_line_items = [%{id: one.id}, %{id: two.id}, %{id: three.id}]
      params = %{line_items: Model.LineItem.update_price_and_totals(new_line_items)}
      new_order = Schema.Order.changeset(persisted, params, :update)
      %{valid?: validity, changes: changes} = new_order

      assert validity
      assert {:ok, _} = Snitch.Repo.update(new_order)
      assert changes == %{}
    end
  end

  defp duplicate_line_items(context) do
    %{variants: [v | _]} = context
    variant_ids = [v.id, v.id, v.id]

    line_items =
      variant_ids
      |> Enum.into([], fn variant_id ->
        %{variant_id: variant_id, quantity: 2}
      end)

    Map.put(context, :line_items, line_items)
  end

  defp good_line_items(context) do
    %{variants: vs} = context
    variant_ids = Stream.map(vs, fn x -> x.id end)

    line_items =
      variant_ids
      |> Enum.into([], fn variant_id ->
        %{variant_id: variant_id, quantity: 2}
      end)

    Map.put(context, :line_items, line_items)
  end

  defp order_changeset(context) do
    order = build(:order)
    %{user: u, address: a} = context
    line_items = Map.get(context, :line_items, [])

    params = %{
      user_id: u.id,
      billing_address_id: a.id,
      shipping_address_id: a.id,
      line_items: Model.LineItem.update_price_and_totals(line_items)
    }

    Map.put(context, :order, Schema.Order.changeset(order, params, :create))
  end

  defp persist(%{order: order} = context) do
    Map.put(context, :persisted, Snitch.Repo.insert!(order))
  end
end

defmodule Snitch.OrderDocTest do
  use ExUnit.Case, async: true
  alias Snitch.Data.Schema
  import Snitch.Factory

  setup :checkout_repo

  setup do
    insert(:variant)
    :ok
  end

  doctest Schema.Order
end
