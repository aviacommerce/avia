defmodule AdminAppWeb.OrderController do
  use AdminAppWeb, :controller
  alias Snitch.Data.Model.{Order, LineItem}
  alias Snitch.Data.Schema.Variant
  alias Snitch.Repo
  import Ecto.Query

  def index(conn, _params) do
    render(conn, "index.html", %{orders: Repo.preload(Order.get_all(), :user)})
  end

  def show(conn, params) do
    order = load_order(%{number: params["number"]})

    search =
      case params["search"] do
        nil ->
          []

        _ ->
          search_variant(params["search"])
      end

    render(conn, "show.html", %{order: order, search: search})
  end

  def create(conn, _params) do
    current_user = Guardian.Plug.current_resource(conn)
    {:ok, order} = Order.create(%{line_items: [], user_id: current_user.id})
    redirect(conn, to: "/orders/#{order.number}")
  end

  def edit(conn, params) do
    order = load_order(%{number: params["number"]})

    render(conn, "show.html", %{order: order, search: []})
  end

  def add(conn, params) do
    order = load_order(%{number: params["order_number"]})
    variant_id = String.to_integer(params["add"])
    IO.inspect(params)
    # quantity = String.to_integer(params["quantity"])
    quantity = 3
    add_line_item = %{quantity: quantity, variant_id: variant_id}
    new_item_list = [add_line_item | struct_to_map(order.line_items)]

    case Order.update(%{line_items: new_item_list}, order) do
      {:ok, order} ->
        redirect(conn, to: "/orders/#{order.number}")

      {:error, error} ->
        %{errors: [line_items: {error_text, _}]} = error
        conn = conn |> put_flash(:error, error_text)
        redirect(conn, to: "/orders/#{order.number}")
    end
  end

  def update(conn, params) do
    order = load_order(%{number: params["order_number"]})

    edit_item = params["edit"]

    line_items = remove_line_item(edit_item, order.line_items)
    edit_line_item = get_line_item(edit_item, order.line_items)

    {:ok, order} =
      Order.update(
        %{
          line_items: line_items
        },
        order
      )

    redirect(conn, to: "/orders/#{order.number}")
  end

  def index_address(conn, params) do
    order = load_order(%{number: params["order_number"]})

    render(conn, "address_add.html", %{order: order})
  end

  def add_address(conn, params) do
    number = params["order_number"]
    redirect(conn, to: "/orders/#{number}")
  end

  defp remove_line_item(edit_item, line_items) do
    line_items
    |> Enum.reject(fn %{id: id} -> id == String.to_integer(edit_item) end)
    |> Enum.map(fn item -> Map.from_struct(item) |> Map.drop([:__meta]) end)
  end

  defp get_line_item(edit_item, line_items) do
    line_items
    |> Enum.reject(fn %{id: id} -> id != String.to_integer(edit_item) end)
    |> Enum.map(fn item -> Map.from_struct(item) |> Map.drop([:__meta]) end)
  end

  defp struct_to_map(items) do
    items
    |> Enum.map(fn item -> Map.from_struct(item) |> Map.drop([:__meta]) end)
  end

  defp search_variant(search) do
    query =
      from(
        u in Variant,
        where: ilike(u.sku, ^"%#{search}%")
      )

    Repo.all(query)
  end

  defp load_order(order) do
    order
    |> Order.get()
    |> Repo.preload(line_items: [:variant])
  end
end
