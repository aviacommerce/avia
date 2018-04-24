defmodule AdminAppWeb.OrderController do
  use AdminAppWeb, :controller
  alias Snitch.Data.Model.Order
  alias Snitch.Repo

  def index(conn, _params) do
    render(conn, "index.html", %{orders: Order.get_all() |> Repo.preload(:user)})
  end

  def show(conn, %{"slug" => slug} = params) do
    render(conn, "show.html", %{order: Order.get(%{slug: slug})})
  end

  def edit(conn, params) do
    render(conn, "edit.html", params)
  end

  def update(conn, params) do
    render(conn, "show.html", params)
  end
end
