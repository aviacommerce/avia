defmodule SnitchApi.Order do
  @moduledoc """
  The Checkout context.
  """

  import Ecto.Query, only: [from: 2, order_by: 2]

  alias Snitch.Repo
  alias SnitchApi.API
  alias Snitch.Data.Schema.Address
  alias Snitch.Data.Model.Order

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

  defp get_address(id), do: Repo.get(Address, id)
end
