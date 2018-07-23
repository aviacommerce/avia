defmodule Snitch.Data.Model.LineItemTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase

  import Mox, only: [expect: 3, verify_on_exit!: 1]
  import Snitch.Factory

  alias Snitch.Data.Model.{LineItem, Order}

  describe "with valid params" do
    setup :variants
    setup :good_line_items

    test "update_unit_price/1", context do
      %{line_items: line_items} = context
      priced_items = LineItem.update_unit_price(line_items)
      assert Enum.all?(priced_items, fn %{unit_price: price} -> not is_nil(price) end)
    end

    test "compute_total/1", context do
      %{line_items: line_items} = context
      priced_items = LineItem.update_unit_price(line_items)
      assert %Money{} = LineItem.compute_total(priced_items)
    end
  end

  describe "with invalid params" do
    setup :variants
    setup :bad_line_items

    test "update_unit_price/1", %{line_items: line_items} do
      priced_items = LineItem.update_unit_price(line_items)

      assert [
               %{quantity: 2, variant_id: -1},
               %{quantity: nil, unit_price: %Money{}, variant_id: _},
               %{quantity: 2, variant_id: nil}
             ] = priced_items
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

    @tag variant_count: 1
    test "fails without an existing order or variant", %{variants: [v]} do
      assert {:error, changeset} = LineItem.create(%{line_item_params(v) | order_id: -1})

      assert %{order: ["does not exist"]} == errors_on(changeset)

      assert {:error, changeset} = LineItem.create(line_item_params(v))
      assert %{order_id: ["can't be blank"]} == errors_on(changeset)

      order = insert(:order)

      assert {:error, changeset} =
               LineItem.create(%{line_item_params(v) | variant_id: -1, order_id: order.id})

      assert %{variant: ["does not exist"]} == errors_on(changeset)

      assert {:error, changeset} =
               LineItem.create(%{line_item_params(v) | variant_id: nil, order_id: order.id})

      assert %{variant_id: ["can't be blank"]} == errors_on(changeset)
    end

    @tag variant_count: 1
    test "for an empty order", %{variants: [v]} do
      order = insert(:order, line_items: [])

      assert {:ok, _} = LineItem.create(%{line_item_params(v) | order_id: order.id})
    end
  end

  describe "update/1" do
    setup :variants
    setup :orders

    @tag variant_count: 1
    test "with valid params", %{variants: [v], orders: [order]} do
      order = struct(order, line_items(%{order: order, variants: [v]}))

      [li] = order.line_items

      params = %{quantity: li.quantity + 1}

      assert {:ok, _} = LineItem.update(li, params)
    end
  end

  describe "delete/1 for order in `cart` state" do
    setup :variants
    setup :orders

    @tag variant_count: 1
    test "with valid params", %{variants: [v], orders: [order]} do
      order = struct(order, line_items(%{order: order, variants: [v]}))

      [line_item] = order.line_items

      {:ok, _} = LineItem.delete(line_item)

      assert [] =
               order.id
               |> Order.get()
               |> Repo.preload(:line_items)
               |> Map.fetch!(:line_items)
    end
  end

  defp good_line_items(context) do
    %{variants: vs} = context
    quantities = Stream.cycle([2])

    line_items =
      vs
      |> Stream.zip(quantities)
      |> Enum.reduce([], fn {variant, quantity}, acc ->
        [%{variant_id: variant.id, quantity: quantity} | acc]
      end)

    [line_items: line_items]
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
