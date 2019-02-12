defmodule AdminAppWeb.OrderChannel do
  @moduledoc """
  Module to manage order searches.
  """
  use Phoenix.Channel
  alias AdminApp.Order.SearchContext
  alias Snitch.Core.Tools.MultiTenancy.Repo

  @doc """
  To authorize clients to join order search topic
  """
  def join("order:search", _message, socket) do
    {:ok, socket}
  end

  def join("order:" <> _private_room_id, _params, _socket) do
    {:error, %{reason: "unauthorized"}}
  end

  @doc """
  To handle incoming order search events and grab the payload passed by
  client over the channel.
  """
  def handle_in("order:search", payload, socket) do
    Repo.set_tenant(socket.assigns.tenant)
    orders = SearchContext.search_orders(payload)

    conn = %Plug.Conn{params: payload}

    broadcast!(socket, "order:search:#{socket.assigns.user_token}", %{
      body:
        Phoenix.View.render_to_string(AdminAppWeb.OrderView, "order_listing.html",
          conn: conn,
          orders: orders,
          token: socket.assigns.user_token,
          start_date: payload["start_date"],
          end_date: payload["end_date"]
        )
    })

    {:noreply, socket}
  end
end
