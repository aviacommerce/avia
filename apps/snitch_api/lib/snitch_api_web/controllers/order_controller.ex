defmodule SnitchApiWeb.OrderController do
  use SnitchApiWeb, :controller

  alias Snitch.Data.Model.Order, as: OrderModel
  alias Snitch.Data.Schema.Order
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
      order = order |> Repo.preload(line_items: [product: [:theme, [options: :option_type]]])

      conn
      |> put_status(200)
      |> put_resp_header("location", order_path(conn, :show, Map.get(order, :id)))
      |> render("show.json-api", data: order)
    end
  end

  def select_address(conn, %{"id" => order_id} = params) do
    shipping_address =
      for {key, val} <- params["shipping_address"], into: %{}, do: {String.to_atom(key), val}

    billing_address =
      for {key, val} <- params["billing_address"],
          into: %{},
          do: {String.to_atom(key), val} || shipping_address

    with {:ok, order} <- OrderContext.attach_address(order_id, shipping_address, billing_address) do
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
      order = order |> Repo.preload(line_items: [product: [:theme, [options: :option_type]]])

      conn
      |> put_status(200)
      |> put_resp_header("location", order_path(conn, :show, order))
      |> render(
        "show.json-api",
        data: order,
        opts: [
          include:
            "line_items,line_items.product,line_items.product.options,line_items.product.options.option_type"
        ]
      )
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
    order = order |> Repo.preload(line_items: [product: [:theme, [options: :option_type]]])

    conn
    |> put_status(200)
    |> put_resp_header("location", order_path(conn, :show, order))
    |> render("show.json-api", data: order)
  end

  def add_payment(conn, %{
        "payment_method_id" => payment_method_id,
        "id" => order_id,
        "amount" => amount
      }) do
    amount = Money.new(:USD, amount)

    with {:ok, order} <- OrderContext.add_payment(order_id, payment_method_id, amount) do
      order = Repo.preload(order, :payments)

      render(
        conn,
        "show.json-api",
        data: order,
        opts: [include: "payments"]
      )
    end
  end
end
