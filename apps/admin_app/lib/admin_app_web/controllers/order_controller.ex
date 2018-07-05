defmodule AdminAppWeb.OrderController do
  use AdminAppWeb, :controller
  alias Snitch.Data.Model.Order
  alias Snitch.Data.Schema.Variant
  alias Snitch.Data.Schema.Address
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
    quantity = String.to_integer(params["quantity"])
    add_line_item = %{quantity: quantity, variant_id: variant_id}
    new_item_list = [add_line_item | struct_to_map(order.line_items)]

    case Order.update(%{line_items: new_item_list}, order) do
      {:ok, order} ->
        redirect(conn, to: "/orders/#{order.number}")

      {:error, error} ->
        %{errors: [line_items: {error_text, _}]} = error
        conn = put_flash(conn, :error, error_text)
        redirect(conn, to: "/orders/#{order.number}")
    end
  end

  def update(conn, params) do
    order = load_order(%{number: params["order_number"]})

    edit_item = params["edit"]

    line_items = remove_line_item(edit_item, order.line_items)

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
    order = load_order(%{number: params["order_number"]})
    changeset = Address.changeset(%Address{}, params["address"])

    case changeset.valid? do
      true ->
        {:ok, address} = Repo.insert(changeset)

        {:ok, order} =
          Order.update(
            %{
              shipping_address_id: address.id,
              billing_address_id: address.id
            },
            order
          )

        redirect(conn, to: "/orders/#{order.number}")

      false ->
        [error_text | _] = changeset.errors
        {title, {error_value, _}} = error_text
        conn = put_flash(conn, :error, Atom.to_string(title) <> " - " <> error_value)
        redirect(conn, to: "/orders/#{order.number}")
    end
  end

  defp remove_line_item(edit_item, line_items) do
    line_items
    |> Enum.reject(fn %{id: id} -> id == String.to_integer(edit_item) end)
    |> Enum.map(fn item -> Map.from_struct(item) |> Map.drop([:__meta]) end)
  end

  defp struct_to_map(items) do
    Enum.map(items, fn item -> Map.from_struct(item) |> Map.drop([:__meta]) end)
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
