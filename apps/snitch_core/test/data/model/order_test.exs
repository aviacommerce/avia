defmodule Snitch.Data.Model.OrderTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase

  import Snitch.Factory

  alias Snitch.Data.Model.Order

  setup :variants
  setup :user_with_address

  @zero_inr Money.new(0, :INR)

  describe "create/3" do
    setup :line_items_from_variants
    setup :order_params

    test "with valid data", %{order_params: params, line_items: line_items} do
      {:ok, _order} = Order.create(params, line_items)
    end

    test "without line_items", %{order_params: params} do
      {:error, changeset} = Order.create(params, [])
      assert errors_on(changeset) == %{line_items: ["can't be blank"]}
    end
  end

  describe "update/3" do
    setup :order_for_update

    test "params, but retain all line-items", %{order: order} do
      line_items = extract_ids(order.line_items)
      params = %{slug: "chichuahua", line_items: line_items}

      {:ok, _order} = Order.update(params, order)
    end

    @tag variant_count: 4
    test "add some line_items", %{order: order, variants: variants} do
      v = List.last(variants)
      old_line_items = extract_ids(order.line_items)
      line_items = [%{variant_id: v.id, quantity: 3} | old_line_items]

      {:ok, %{line_items: new_items}} = Order.update(%{line_items: line_items}, order)
      assert Enum.count(new_items) == 4
      assert Enum.all?(old_line_items, fn x -> x in extract_ids(new_items) end)
    end

    test "remove some line_items", %{order: order} do
      line_items =
        order.line_items
        |> List.first()
        |> List.wrap()
        |> extract_ids()

      {:ok, %{line_items: new_items}} = Order.update(%{line_items: line_items}, order)
      assert Enum.count(new_items) == 1
    end

    test "remove all line_items", %{order: order} do
      assert_raise RuntimeError, "default currency not set", fn ->
        Order.update(%{line_items: []}, order)
      end

      # TODO: Mock the Application config!
      Application.put_env(:snitch_core, :core_config_app, :snitch)
      Application.put_env(:snitch, :defaults, currency: :INR)

      assert {:ok,
              %{
                item_total: @zero_inr,
                total: @zero_inr
              }} = Order.update(%{line_items: []}, order)

      Application.delete_env(:snitch_core, :core_config_app)
      Application.delete_env(:snitch, :defaults)
    end

    test "update few items", %{order: order} do
      [one, two, three] = extract_ids(order.line_items, [:quantity, :variant_id])
      line_items = [%{one | quantity: 42}, two, %{three | quantity: 1}]
      {:ok, %{line_items: new_items}} = Order.update(%{line_items: line_items}, order)
      assert Enum.map(new_items, &Map.fetch!(&1, :quantity)) == [42, 2, 1]
    end

    @tag variant_count: 4
    test "update one, add one, remove one, retain one", %{order: order, variants: variants} do
      v = List.last(variants)
      [_, two, three] = extract_ids(order.line_items, [:quantity, :variant_id])
      line_items = [%{two | quantity: 42}, three, %{variant_id: v.id, quantity: 3}]
      {:ok, %{line_items: new_items}} = Order.update(%{line_items: line_items}, order)
      assert Enum.map(new_items, &Map.fetch!(&1, :quantity)) == [42, 2, 3]
    end
  end

  defp order_for_update(context) do
    [{_, line_items}] = line_items_from_variants(context)
    [{_, params}] = order_params(context)

    {:ok, order} = Order.create(params, line_items)
    [order: order]
  end

  defp line_items_from_variants(%{variants: variants} = context) do
    count = Map.get(context, :line_item_count, 3)

    line_items =
      variants
      |> Enum.take(count)
      |> Enum.reduce([], fn v, acc ->
        [%{variant_id: v.id, quantity: 2} | acc]
      end)

    [line_items: line_items]
  end

  defp order_params(%{user: user}) do
    [
      order_params: %{
        user_id: user.id,
        slug: "mammoth"
      }
    ]
  end

  # This guys does some magic. Builds a list of transform functions, one for each
  # `key` in `others`.
  defp extract_ids(items, others \\ []) do
    transforms =
      others
      |> Enum.map(fn key ->
        fn acc, struct ->
          value = Map.fetch!(struct, key)
          Map.put(acc, key, value)
        end
      end)

    Enum.reduce(items, [], fn x, acc ->
      datum = Enum.reduce(transforms, %{id: x.id}, fn t, acc -> t.(acc, x) end)
      [datum | acc]
    end)
  end
end
