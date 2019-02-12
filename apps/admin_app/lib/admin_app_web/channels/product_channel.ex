defmodule AdminAppWeb.ProductChannel do
  @moduledoc """
  Module to manage product searches.
  """
  use Phoenix.Channel
  alias AdminApp.Product.SearchContext
  alias Snitch.Core.Tools.MultiTenancy.Repo

  def join("product:search", _message, socket) do
    {:ok, socket}
  end

  def join("product:" <> _private_room_id, _params, _socket) do
    {:error, %{reason: "unauthorized"}}
  end

  def handle_in("product:search", payload, socket) do
    Repo.set_tenant(socket.assigns.tenant)
    products = SearchContext.search_products_by_name(payload["term"])

    conn = %Plug.Conn{
      query_params: %{
        "rummage" => %{
          "search" => %{
            "state" => %{
              "search_expr" => "where",
              "search_term" => "active",
              "search_type" => "eq"
            }
          },
          "sort" => %{"field" => "name", "order" => "asc"}
        }
      }
    }

    broadcast!(socket, "product:search:#{socket.assigns.user_token}", %{
      body:
        Phoenix.View.render_to_string(AdminAppWeb.ProductView, "index.html",
          conn: conn,
          products: products
        )
    })

    {:noreply, socket}
  end
end
