defmodule AdminAppWeb.OrderController do
  use AdminAppWeb, :controller
  alias Snitch.Data.Model.Order
  alias Snitch.Repo

  def index(conn, _params) do
    render(conn, "index.html", %{orders: Repo.preload(Order.get_all(), :user)})
  end

  def show(conn, %{"slug" => slug} = _params) do
    order =
      %{slug: slug}
      |> Order.get()
      |> Repo.preload(line_items: [:variant], billing_address: [], shipping_address: [])

    render(conn, "show.html", %{order: order})
  end

  def edit(conn, params) do
    render(conn, "edit.html", params)
  end

  def update(conn, params) do
    render(conn, "show.html", params)
  end
end
