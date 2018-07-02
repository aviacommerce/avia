defmodule Snitch.Data.Model.LineItemTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase

  import Mox, only: [expect: 3, verify_on_exit!: 1]
  import Snitch.Factory

  alias Snitch.Data.Model.LineItem

  describe "with valid params" do
    setup :variants
    setup :good_line_items

    test "update_price_and_totals/1", context do
      %{line_items: line_items, totals: totals} = context
      priced_items = LineItem.update_price_and_totals(line_items)
      assert Enum.all?(priced_items, fn x -> totals[x.variant_id] == Money.reduce(x.total) end)
    end

    test "compute_totals/1", context do
      %{line_items: line_items} = context
      priced_items = LineItem.update_price_and_totals(line_items)
      assert %Money{} = LineItem.compute_total(priced_items)
    end
  end

  describe "with invalid params" do
    setup :variants
    setup :bad_line_items

    test "update_price_and_totals/1", context do
      %{line_items: line_items} = context
      priced_items = LineItem.update_price_and_totals(line_items)

      assert Enum.all?(priced_items, &(not Map.has_key?(&1, :total)))
      assert Enum.all?(priced_items, &(not Map.has_key?(&1, :unit_price)))
    end
  end

  describe "compute_total/1 with empty list" do
    setup :verify_on_exit!

    test "when default currency is set" do
      expect(Snitch.Tools.DefaultsMock, :fetch, fn :currency -> {:ok, :INR} end)
      assert Money.zero(:INR) == LineItem.compute_total([])
    end

    test "when default currency is not set" do
      expect(Snitch.Tools.DefaultsMock, :fetch, fn :currency -> {:error, "whatever"} end)

      assert_raise RuntimeError, "whatever", fn ->
        LineItem.compute_total([])
      end
    end
  end

  describe "create/1" do
    setup :variants
    setup :user_with_address

    @tag variant_count: 1
    test "fails without an existing order", %{variants: [v]} do
      assert {:error, :line_item, changeset, %{}} =
               LineItem.create(%{line_item_params(v) | order_id: -1})

      assert %{order_id: ["does not exist"]} = errors_on(changeset)

      assert {:error, :line_item, changeset, %{}} = LineItem.create(line_item_params(v))

      assert %{order_id: ["can't be blank"]} = errors_on(changeset)
    end
  end

  describe "create/1 for order in `cart` state" do
    setup :variants
    setup :user_with_address

    @tag variant_count: 1
    test "which is empty", %{variants: [v], user: user} do
      order = insert(:order, line_items: [], user: user)

      {:ok, li} = LineItem.create(%{line_item_params(v) | order_id: order.id})
      assert Ecto.assoc_loaded?(li.order)
      assert Ecto.assoc_loaded?(li.order.line_items)
      assert length(li.order.line_items) == 1
    end

    @tag variant_count: 2
    test "with existing line_items", %{variants: [v1, v2], user: user} do
      order = insert(:order, user: user)
      order = struct(order, line_items(%{order: order, variants: [v1]}))

      assert length(order.line_items) == 1
      [li] = order.line_items
      assert li.variant_id == v1.id

      {:ok, li} = LineItem.create(%{line_item_params(v2) | order_id: order.id})
      assert Ecto.assoc_loaded?(li.order)
      assert Ecto.assoc_loaded?(li.order.line_items)
      assert length(li.order.line_items) == 2
    end
  end

  describe "update/1 for order in `cart` state" do
    setup :variants
    setup :user_with_address

    @tag variant_count: 1
    test "fails with invalid params", %{variants: [v], user: user} do
      order = insert(:order, user: user)
      order = struct(order, line_items(%{order: order, variants: [v]}))

      [li] = order.line_items

      params = %{
        quantity: li.quantity + 1
      }

      {:error, :line_item, cs, %{}} = LineItem.update(li, params)
      assert %{total: ["can't be blank"]} = errors_on(cs)
    end

    @tag variant_count: 1
    test "with valid params", %{variants: [v], user: user} do
      order = insert(:order, user: user)
      order = struct(order, line_items(%{order: order, variants: [v]}))

      [li] = order.line_items

      params = %{
        quantity: li.quantity + 1,
        total: Money.add!(li.total, li.unit_price)
      }

      {:ok, li} = LineItem.update(li, params)
      assert Ecto.assoc_loaded?(li.order)
      assert Ecto.assoc_loaded?(li.order.line_items)
      assert length(li.order.line_items) == 1
    end
  end

  describe "delete/1 for order in `cart` state" do
    setup :variants
    setup :user_with_address

    @tag variant_count: 1
    test "with valid params", %{variants: [v], user: user} do
      order = insert(:order, user: user)
      order = struct(order, line_items(%{order: order, variants: [v]}))

      [line_item] = order.line_items

      {:ok, li} = LineItem.delete(line_item)
      assert Ecto.assoc_loaded?(li.order)
      assert Ecto.assoc_loaded?(li.order.line_items)
      assert [] = li.order.line_items
    end
  end

  describe "create/1 for order in `address` state" do
    setup :variants
    setup :user_with_address

    @tag :skip
    @tag variant_count: 1
    test "which is empty", %{variants: [v], user: user} do
      order = insert(:order, line_items: [], user: user)

      {:ok, li} = LineItem.create(%{line_item_params(v) | order_id: order.id})
      assert Ecto.assoc_loaded?(li.order)
      assert Ecto.assoc_loaded?(li.order.line_items)
      assert length(li.order.line_items) == 1
      assert order.item_total == li.total
      assert order.total == li.total
    end

    @tag :skip
    @tag variant_count: 2
    test "with existing line_items", %{variants: [v1, v2], user: user} do
      order =
        insert(
          :order,
          item_total: v1.selling_price,
          total: v1.selling_price,
          user: user,
          state: "address"
        )

      order = struct(order, line_items(%{order: order, variants: [v1]}))

      assert length(order.line_items) == 1
      [li] = order.line_items
      assert li.variant_id == v1.id

      {:ok, li} = LineItem.create(%{line_item_params(v2) | order_id: order.id})
      assert Money.reduce(li.order.item_total) == Money.add!(li.total, v1.selling_price)
      assert Money.reduce(li.order.total) == Money.add!(li.total, v1.selling_price)
    end
  end

  defp good_line_items(context) do
    %{variants: vs} = context
    quantities = Stream.cycle([2])

    {line_items, totals} =
      vs
      |> Stream.zip(quantities)
      |> Enum.reduce({[], %{}}, fn {variant, quantity}, {ls, ts} ->
        {
          [%{variant_id: variant.id, quantity: quantity} | ls],
          Map.put(ts, variant.id, Money.mult!(variant.selling_price, quantity))
        }
      end)

    [line_items: line_items, totals: totals]
  end

  defp bad_line_items(context) do
    %{variants: [one, two, three]} = context
    variants = [%{one | id: -1}, two, %{three | id: nil}]
    quantities = [2, nil, 2]

    line_items =
      variants
      |> Stream.zip(quantities)
      |> Enum.map(fn {variant, quantity} ->
        %{variant_id: variant.id, quantity: quantity}
      end)

    [line_items: line_items]
  end

  defp line_item_params(variant) do
    %{
      quantity: 1,
      unit_price: variant.selling_price,
      total: variant.selling_price,
      order_id: nil,
      variant_id: variant.id
    }
  end
end

defmodule Snitch.Data.Model.LineItemDocTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase

  import Snitch.Factory

  alias Snitch.Data.Model

  setup do
    insert(:variant)
    :ok
  end

  doctest Snitch.Data.Model.LineItem
end
