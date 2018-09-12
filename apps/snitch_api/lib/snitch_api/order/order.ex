defmodule SnitchApi.Order do
  @moduledoc """
  The Checkout context.
  """

  import Ecto.Query

  alias Snitch.Repo
  alias Snitch.Data.Model.LineItem, as: LineItemModel
  alias Snitch.Data.Model.Order, as: OrderModel
  alias BeepBop.Context
  alias Snitch.Data.Model.{Order, PaymentMethod}
  alias Snitch.Data.Schema.LineItem
  alias Snitch.Domain.Order.DefaultMachine

  @doc """
  Attaching address to order.

  Updates order with the supplied billing and shipping address.
  """

  def attach_address(order_id, shipping_address, billing_address) do
    order = Order.get(order_id) |> Repo.preload([:payments, :packages])

    context =
      order
      |> Context.new(
        state: %{
          billing_address: billing_address,
          shipping_address: shipping_address
        }
      )

    transition = transition_to_address(order.state, context)
    transition_response(transition, order_id)
  end

  def load_order(order_id) do
    line_item_query = from(LineItem, order_by: [desc: :inserted_at], preload: [product: :theme])
    order = Repo.preload(OrderModel.get(order_id), line_items: line_item_query)
  end

  def delete_line_item(line_item_id) do
    with %LineItem{} = line_item <- LineItemModel.get(line_item_id),
         {:ok, _} <- LineItemModel.delete(line_item) do
      {:ok, line_item}
    else
      nil -> {:error, :not_found}
    end
  end

  def add_to_cart(line_item) do
    case get_line_item(line_item["order_id"], line_item["product_id"]) do
      [] -> LineItemModel.create(line_item)
      [l | _] -> update_line_item(l, line_item)
    end
  end

  def add_payment(order_id, payment_method_id, amount) do
    with order when not is_nil(order) <- Order.get(order_id),
         payment_method when not is_nil(payment_method) <- PaymentMethod.get(payment_method_id) do
      context =
        order
        |> Context.new(
          state: %{
            payment_method: payment_method,
            payment_params: %{
              payment_params: %{
                amount: amount
              },
              subtype_params: %{}
            }
          }
        )

      transition = DefaultMachine.add_payment(context)
      transition_response(transition, order_id)
    else
      nil ->
        {:error, :not_found}
    end
  end

  defp get_line_item(order_id, product_id) do
    query = from(l in LineItem, where: l.order_id == ^order_id and l.product_id == ^product_id)
    Repo.all(query)
  end

  defp update_line_item(line_item, params) do
    new_count = line_item.quantity + params["quantity"]
    new_params = %{params | "quantity" => new_count}
    LineItemModel.update(line_item, new_params)
  end

  defp transition_response(%Context{errors: nil}, order_id) do
    order =
      Order.get(order_id)
      |> Repo.preload(line_items: [product: [:theme, [options: :option_type]]])

    {:ok, order}
  end

  defp transition_response(%Context{errors: errors}, _) do
    errors
  end

  defp transition_to_address("cart", context) do
    DefaultMachine.add_addresses(context)
  end

  defp transition_to_address("address", context) do
    DefaultMachine.delivery_to_address(context)
  end

  defp transition_to_address("delivery", context) do
    DefaultMachine.delivery_to_address(context)
  end

  defp transition_to_address("payment", context) do
    DefaultMachine.payment_to_address(context)
  end
end
