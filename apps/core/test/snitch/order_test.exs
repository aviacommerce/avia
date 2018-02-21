defmodule Core.Snitch.OrderTest do
  use ExUnit.Case, async: true
  alias Core.Snitch.{Order, LineItem}
  import Core.Snitch.Factory

  setup :checkout_repo

  describe "order totals are updated and line_items are inserted to DB" do
    setup [:three_variants, :a_user_and_address, :good_line_items, :order_changeset]

    test "", context do
      %{order: order} = context
      %{valid?: validity, changes: changes} = order
      assert validity
      assert Map.has_key?(changes, :item_total)
      assert Enum.all?(changes.line_items, fn %{action: action} -> action == :insert end)
      # check DB level constraints too
      assert {:ok, _} = Core.Repo.insert(order)
    end
  end

  describe "order can handle duplicate line_items" do
    setup [:three_variants, :a_user_and_address, :duplicate_line_items, :order_changeset]

    test "", context do
      %{order: order} = context
      %{valid?: validity, changes: changes, errors: [error]} = order
      refute validity
      refute Map.has_key?(changes, :item_total)
      assert Enum.all?(changes.line_items, fn %{valid?: validity} -> validity end)
      assert error == {:duplicate_variants, {"line_items must have unique variant_ids", []}}
    end
  end

  defp duplicate_line_items(context) do
    %{variants: [v | _]} = context
    variant_ids = Stream.cycle([v.id]) |> Enum.take(3)

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
    order = build(:basic_order)
    %{user: u, address: a, line_items: line_items} = context

    params = %{
      user_id: u.id,
      billing_address_id: a.id,
      shipping_address_id: a.id,
      line_items: LineItem.update_price_and_totals(line_items)
    }

    Map.put(context, :order, Order.create_changeset(order, params))
  end
end
