defmodule SnitchApiWeb.OrderController do
  use SnitchApiWeb, :controller

  alias Snitch.Data.Model.Order, as: OrderModel
  alias Snitch.Data.Schema.Order
  alias Snitch.Data.Schema.OrderAddress
  alias SnitchApi.Order, as: OrderContext
  alias Snitch.Repo

  action_fallback(SnitchApiWeb.FallbackController)
  plug(SnitchApiWeb.Plug.DataToAttributes)
  plug(SnitchApiWeb.Plug.LoadUser)

  def index(conn, params) do
    user = conn.assigns.current_user
    orders = Repo.preload(OrderModel.user_orders(user.id), :line_items)

    render(
      conn,
      "index.json-api",
      data: orders,
      opts: [
        include: params["include"],
        fields: conn.query_params["fields"]
      ]
    )
  end

  def show(conn, %{"id" => id}) do
    order = Snitch.Repo.get!(Order, id)

    render(
      conn,
      "show.json-api",
      data: order
    )
  end

  def guest_order(conn, _params) do
    with {:ok, %Order{} = order} <- OrderModel.create_guest_order() do
      conn
      |> put_status(200)
      |> put_resp_header("location", order_path(conn, :show, Map.get(order, :id)))
      |> render("show.json-api", data: order)
    end
  end

  def select_address(conn, %{"id" => order_id} = params) do
    order = OrderModel.get(order_id)

    shipping_address =
      for {key, val} <- params["shipping_address"], into: %{}, do: {String.to_atom(key), val}

    billing_address =
      for {key, val} <- params["shipping_address"], into: %{}, do: {String.to_atom(key), val}

    shipping_address =
      shipping_address
      |> Map.update!(:country_id, &String.to_integer/1)
      |> Map.update!(:state_id, &String.to_integer/1)

    billing_address =
      billing_address
      |> Map.update!(:country_id, &String.to_integer/1)
      |> Map.update!(:state_id, &String.to_integer/1)

    order_address = %{
      shipping_address: shipping_address,
      billing_address: billing_address
    }

    with {:ok, %Order{} = order} <- OrderModel.partial_update(order, order_address) do
      conn
      |> put_status(200)
      |> render(
        "show.json-api",
        data: order,
        opts: [
          include: params["include"],
          fields: conn.query_params["fields"]
        ]
      )
    end
  end

  def fetch_guest_order(conn, %{"order_number" => order_number}) do
    with %Order{} = order <- OrderModel.get(%{number: order_number}) do
      conn
      |> put_status(200)
      |> put_resp_header("location", order_path(conn, :show, order))
      |> render("show.json-api", data: order)
    else
      nil ->
        conn
        |> put_status(200)
        |> render("empty.json-api", data: %{})
    end
  end

  def current(conn, _params) do
    user_id = Map.get(conn.assigns[:current_user], :id)

    {:ok, order} = OrderModel.user_order(user_id)

    conn
    |> put_status(200)
    |> put_resp_header("location", order_path(conn, :show, order))
    |> render("show.json-api", data: order)
  end
end
