defmodule SnitchApi.Order do
  @moduledoc """
  The Checkout context.
  """

  import Ecto.Query, only: [from: 2, order_by: 2]

  alias Snitch.Repo
  alias SnitchApi.API
  alias Snitch.Data.Schema.{Address, LineItem}
  alias Snitch.Data.Model.Order
  alias Snitch.Data.Model.LineItem, as: LineItemModel
  import Ecto.Query

  @doc """
    Attaching address to order.
    Featch address from using ID.

    Update order embeded address to order using partial_update
  """

  def attach_address(order_id, address_id) do
    address =
      address_id
      |> get_address()
      |> Map.from_struct()

    %{id: order_id}
    |> Order.get()
    |> Repo.preload(:line_items)
    |> Order.partial_update(%{
      billing_address: address,
      shipping_address: address
    })
  end

  def add_to_cart(line_item) do
    case get_line_item(line_item["order_id"], line_item["product_id"]) do
      [] -> LineItemModel.create(line_item)
      [l | _] -> update_line_item(l, line_item)
    end
  end

  defp get_address(id), do: Repo.get(Address, id)

  defp get_line_item(order_id, product_id) do
    query = from(l in LineItem, where: l.order_id == ^order_id and l.product_id == ^product_id)
    Repo.all(query)
  end

  defp update_line_item(line_item, params) do
    new_count = line_item.quantity + params["quantity"]
    new_params = %{params | "quantity" => new_count}
    LineItemModel.update(line_item, new_params)
  end
end
