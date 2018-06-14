defmodule Snitch.Data.Schema.OrderTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase

  import Snitch.Factory

  alias Snitch.Data.Model.LineItem
  alias Snitch.Data.Schema.Order

  setup :variants
  setup :user_with_address
  setup :some_line_items
  setup :order_changeset

  @tag line_item_type: :valid
  test "order totals are updated and line_items are inserted to DB", context do
    %{order: order} = context
    %{valid?: validity, changes: changes} = order
    assert validity
    assert Map.has_key?(changes, :item_total)
    assert Enum.all?(changes.line_items, fn %{action: action} -> action == :insert end)
    # check DB level constraints too
    assert {:ok, _} = Repo.insert(order)
  end

  @tag line_item_type: :duplicate
  test "order can handle duplicate line_items", context do
    %{order: order} = context
    %{valid?: validity, changes: changes, errors: [error]} = order
    refute validity
    refute Map.has_key?(changes, :item_total)
    assert Enum.all?(changes.line_items, fn %{valid?: validity} -> validity end)
    assert error == {:duplicate_variants, {"line_items must have unique variant_ids", []}}
  end

  @tag line_item_type: :none
  test "order cannot be created without line_items", context do
    %{order: order} = context
    %{valid?: validity, errors: [error]} = order
    refute validity
    assert error == {:line_items, {"can't be blank", [validation: :required]}}
  end

  describe "order updates" do
    setup :persist

    @tag line_item_type: :valid
    test "unassociated line_items", context do
      %{persisted: persisted, line_items: line_items} = context
      params = %{line_items: LineItem.update_price_and_totals(line_items)}
      new_order = Order.update_changeset(persisted, params)
      %{valid?: validity, changes: changes} = new_order

      assert validity
      assert {:ok, _} = Repo.update(new_order)
      assert Enum.all?(changes.line_items, fn x -> x.action in [:insert, :replace] end)
    end

    @tag line_item_type: :valid
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
      params = %{line_items: LineItem.update_price_and_totals(new_line_items)}

      new_order = Order.update_changeset(persisted, params)
      %{valid?: validity, changes: changes} = new_order

      assert validity
      assert {:ok, _} = Repo.update(new_order)
      assert Map.fetch!(changes, :item_total) == Money.reduce(total)
      assert Enum.all?(changes.line_items, fn x -> x.action == :update end)
    end

    @tag line_item_type: :valid
    test "no changes, bud!", context do
      %{persisted: persisted} = context
      [one, two, three] = persisted.line_items
      new_line_items = [%{id: one.id}, %{id: two.id}, %{id: three.id}]
      params = %{line_items: LineItem.update_price_and_totals(new_line_items)}
      new_order = Order.update_changeset(persisted, params)
      %{valid?: validity, changes: changes} = new_order

      assert validity
      assert {:ok, _} = Repo.update(new_order)
      assert changes == %{}
    end
  end

  defp some_line_items(context) do
    %{variants: vs} = context
    v = List.first(vs)

    variant_ids =
      case context[:line_item_type] do
        :valid ->
          Stream.map(vs, fn x -> x.id end)

        :duplicate ->
          [v.id, v.id, v.id]

        _ ->
          []
      end

    line_items =
      Enum.into(variant_ids, [], fn variant_id ->
        %{variant_id: variant_id, quantity: 2}
      end)

    [line_items: line_items]
  end

  defp order_changeset(context) do
    order = build(:order)
    %{user: u} = context
    line_items = Map.get(context, :line_items, [])

    params = %{
      user_id: u.id,
      line_items: LineItem.update_price_and_totals(line_items)
    }

    [order: Order.create_changeset(order, params)]
  end

  defp persist(%{order: order}) do
    [persisted: Repo.insert!(order)]
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
