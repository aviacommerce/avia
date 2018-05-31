defmodule ApiWeb.OrderController do
  use ApiWeb, :controller

  alias Snitch.Data.Model.{Order, User}
  alias Snitch.Repo
  alias ApiWeb.FallbackController, as: Fallback

  def current(conn, _params) do
    order =
      Order.get_all()
      |> List.first()
      |> Repo.preload(line_items: :variant, shipping_address: [], billing_address: [])

    render(conn, "order.json", order: order)
  end

  def create(conn, %{"line_items" => line_items} = params) do
    do_create(conn, params, line_items)
  end

  def create(conn, params) do
    do_create(conn, params, [])
  end

  defp do_create(conn, params, line_items) do
    user = get_user()
    slug = unique_id()

    params
    |> Map.put(:user_id, user.id)
    |> Map.put(:slug, slug)
    |> Order.create(line_items)
    |> case do
      {:ok, order} ->
        render(conn, "order.json", order: order)

      {:error, _} = error ->
        Fallback.call(conn, error)
    end
  end

  defp get_user do
    List.first(User.get_all())
  end

  defp unique_id do
    UUID.uuid1()
  end

  def add_line_item(conn, params) do
    order_id = Map.fetch!(params, "order_number")
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

  def load_order(order_id) do
    order_id
    |> String.to_integer()
    |> Order.get()
    |> case do
      nil ->
        :error

      order ->
        {:ok,
         Repo.preload(order, line_items: :variant, shipping_address: [], billing_address: [])}
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
      |> Repo.preload(:variant)

    render(conn, "lineitem.json", line_item: item)
  end
end
