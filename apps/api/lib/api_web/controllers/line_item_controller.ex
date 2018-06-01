defmodule ApiWeb.LineItemController do
  use ApiWeb, :controller

  alias Snitch.Repo
  alias Snitch.Data.Model.Order
  alias ApiWeb.FallbackController, as: Fallback

  def create(conn, params) do
    order_id = Map.fetch!(params, "order_id")
    variant_id = Map.fetch!(params["line_item"], "variant_id")
    quantity = Map.fetch!(params["line_item"], "quantity")

    with {:ok, order} <- load_order(order_id) do
      variants = order_variants_list(order.line_items)
      items = items_to_insert(order, variants, variant_id, quantity)

      case Order.update(%{line_items: items}, order) do
        {:ok, order} ->
          added_item(conn, order, variant_id)

        {:error, _} = error ->
          Fallback.call(conn, error)
      end
    else
      :error -> Fallback.call(conn, {:error, :not_found})
    end
  end

  def delete(conn, params) do
    order_id = Map.fetch!(params, "order_id")
    line_item_id = Map.fetch!(params, "id")

    with {:ok, order} <- load_order(order_id) do
      new_line_items =
        order.line_items
        |> Enum.filter(fn x -> x.id != String.to_integer(line_item_id) end)
        |> Enum.map(fn x -> %{id: x.id} end)

      Order.update(%{line_items: new_line_items}, order)
      send_resp(conn, 200, "")
    else
      :error -> Fallback.call(conn, {:error, :not_found})
    end
  end

  defp load_order(order_id) do
    order_id
    |> String.to_integer()
    |> Order.get()
    |> case do
      nil ->
        :error

      order ->
        {:ok,
         Repo.preload(
           order,
           line_items: [variant: :images],
           shipping_address: [],
           billing_address: []
         )}
    end
  end

  defp items_to_insert(order, variants, variant_id, quantity) do
    case MapSet.member?(variants, variant_id) do
      true ->
        line_items_manifest(order.line_items, variant_id, quantity)

      false ->
        old_items = line_items_manifest(order.line_items, variant_id, quantity)
        [%{variant_id: variant_id, quantity: quantity} | old_items]
    end
  end

  defp line_items_manifest(line_items, variant_id, quantity) do
    Enum.reduce(line_items, [], fn line_item, acc ->
      if line_item.variant_id == variant_id do
        [%{id: line_item.id, quantity: line_item.quantity + quantity} | acc]
      else
        [%{id: line_item.id} | acc]
      end
    end)
  end

  defp order_variants_list(line_items) do
    Enum.reduce(line_items, MapSet.new(), fn %{variant_id: id}, acc ->
      MapSet.put(acc, id)
    end)
  end

  defp added_item(conn, order, variant_id) do
    item =
      order.line_items
      |> Enum.find(fn line_item ->
        line_item.variant_id == variant_id
      end)
      |> Repo.preload(variant: :images)

    render(conn, "line_item.json", line_item: item)
  end
end
