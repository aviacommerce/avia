defmodule Core.Snitch.OrderTest do
  use ExUnit.Case, async: true
  alias Core.Snitch.{LineItem, Order}
  import Core.Snitch.Factory

  setup :checkout_repo

  describe "order totals are updated and line_items are inserted to DB" do
    setup [:three_variants, :a_user_and_address, :good_line_items, :order_changeset]

    test "", context do
      %{variants: vs, line_items: lis} = context
      quantities = Stream.map(lis, fn li -> li.quantity end)
      # manually compute the total.
      total =
        vs
        |> Stream.map(fn v -> v.cost_price end)
        |> Stream.zip(quantities)
        |> Stream.map(fn {price, quantity} -> Money.mult!(price, quantity) end)
        |> Enum.reduce(&Money.add!/2)

      %{order: order} = context
      updated_order = Order.update_product_totals_changeset(order)
      %{valid?: validity, changes: changes} = updated_order
      assert validity
      assert Money.reduce(Map.fetch!(changes, :item_total)) == total
      assert Enum.all?(changes.line_items, fn %{valid?: validity} -> validity end)
      assert Enum.all?(changes.line_items, fn %{action: action} -> action == :insert end)
      # Core.Repo.insert!(updated_order)
    end
  end

  describe "order can handle duplicate line_items" do
    setup [:three_variants, :a_user_and_address, :duplicate_line_items, :order_changeset]

    test "", context do
      %{order: order} = context
      %{valid?: validity} = order
      refute validity

      %{valid?: updated_validity, changes: changes, errors: errors} =
        Order.update_product_totals_changeset(order)

      refute updated_validity
      refute Map.has_key?(changes, :item_total)

      assert errors == [
               invalid_line_items: {"could not compute product totals", []},
               duplicate_variants: {"line_items must have unique variant_ids", []}
             ]

      assert Enum.all?(changes.line_items, fn %{valid?: validity} -> validity end)
    end
  end

  describe "order can handle invalid line_items" do
    setup [:three_variants, :a_user_and_address, :line_items_bad_quantity, :order_changeset]

    test "", context do
      %{order: order} = context
      %{valid?: validity} = order
      refute validity

      %{valid?: updated_validity, changes: changes, errors: errors} =
        Order.update_product_totals_changeset(order)

      refute updated_validity
      refute Map.has_key?(changes, :item_total)
      assert errors == [invalid_line_items: {"could not compute product totals", []}]
      assert Enum.all?(changes.line_items, fn %{valid?: validity} -> not validity end)
    end
  end

  defp duplicate_line_items(context) do
    Map.put(context, :line_items, [%{variant_id: 1, quantity: 2}, %{variant_id: 1, quantity: 2}])
  end

  defp line_items_bad_quantity(context) do
    %{variants: vs} = context
    quantities = Stream.cycle([0])
    variant_ids = Stream.map(vs, fn x -> x.id end)

    line_items =
      variant_ids
      |> Stream.zip(quantities)
      |> Enum.into([], fn {variant_id, quantity} ->
        %{variant_id: variant_id, quantity: quantity}
      end)

    Map.put(context, :line_items, line_items)
  end

  defp good_line_items(context) do
    %{variants: vs} = context
    quantities = Stream.cycle([2])
    variant_ids = Stream.map(vs, fn x -> x.id end)

    line_items =
      variant_ids
      |> Stream.zip(quantities)
      |> Enum.into([], fn {variant_id, quantity} ->
        %{variant_id: variant_id, quantity: quantity}
      end)

    Map.put(context, :line_items, line_items)
  end

  defp order_changeset(context) do
    order = build(:basic_order)
    %{user: u, address: a, line_items: line_items} = context

    params = %{
      user_id: u.id,
      billing_address_id: a.id,
      shipping_address_id: a.id,
      line_items: line_items
    }

    Map.put(context, :order, Order.create_changeset(order, params))
  end
end
