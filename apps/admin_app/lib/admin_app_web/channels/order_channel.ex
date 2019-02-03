defmodule AdminAppWeb.OrderChannel do
  use Phoenix.Channel
  alias AdminApp.Order.SearchContext
  alias Snitch.Core.Tools.MultiTenancy.Repo

  def join("order:search", _message, socket) do
    {:ok, socket}
  end

  def join("order:" <> _private_room_id, _params, _socket) do
    {:error, %{reason: "unauthorized"}}
  end

  def handle_in("order:search", payload, socket) do
    Repo.set_tenant(socket.assigns.tenant)
    orders = SearchContext.search_orders(payload)

    conn = %Plug.Conn{}

    broadcast!(socket, "order:search:#{socket.assigns.user_token}", %{
      body:
        Phoenix.View.render_to_string(AdminAppWeb.OrderView, "index.html",
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
