defmodule AdminAppWeb.OrderController do
  use AdminAppWeb, :controller
  alias Snitch.Data.Model.Order
  alias BeepBop.Context
  alias Snitch.Domain.Order.DefaultMachine
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
          search_item_variant(params["search"])
      end

    render(conn, "show.html", %{order: order, search: search})
  end

  def create(conn, _params) do
    current_user = Guardian.Plug.current_resource(conn)
    {:ok, order} = Order.create(%{line_items: [], user_id: current_user.id})

    redirect(conn, to: order_path(conn, :show, order.id))
  end

  def edit(conn, params) do
    order = load_order(%{number: params["order_number"]})

    update_item =
      fetch_line_item(params["update"], order.line_items)
      |> List.first()

    render(conn, "edit.html", %{order: order, search: [], update_item: update_item})
  end

  def update_line_item(conn, params) do
    order = load_order(%{number: params["order_number"]})

    update_item = params["update"]
    line_items = remove_line_item(update_item, order.line_items)
    update_item = List.first(fetch_line_item(update_item, order.line_items))
    updated_list = [%{quantity: params["quantity"], id: update_item.id} | line_items || []]

    case Order.update(%{line_items: updated_list}, order) do
      {:ok, order} ->
        redirect(conn, to: order_path(conn, :show, order.id))

      {:error, error} ->
        %{errors: [line_items: {error_text, _}]} = error
        conn = put_flash(conn, :error, error_text)
        redirect(conn, to: order_path(conn, :show, order.id))
    end

    render(conn, "edit.html", %{order: order, search: [], update_item: update_item})
  end

  def add(conn, params) do
    order = load_order(%{number: params["order_number"]})

    variant_id = String.to_integer(params["add"])
    quantity = String.to_integer(params["quantity"])
    add_line_item = %{quantity: quantity, variant_id: variant_id}
    new_item_list = [add_line_item | struct_to_map(order.line_items)]

    case Order.update(%{line_items: new_item_list}, order) do
      {:ok, order} ->
        redirect(conn, to: order_path(conn, :show, order.id))

      {:error, error} ->
        %{errors: [line_items: {error_text, _}]} = error
        conn = put_flash(conn, :error, error_text)
        redirect(conn, to: order_path(conn, :show, order.id))
    end
  end

  def remove_item(conn, params) do
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

    redirect(conn, to: order_path(conn, :show, order.id))
  end

  def address_add_index(conn, params) do
    order = load_order(%{number: params["order_number"]})

    render(conn, "address_add.html", %{order: order})
  end

  def address_search(conn, params) do
    order = load_order(%{number: params["order_number"]})
    address_list = search_address_list(params["address_search"])

    case address_list do
      [] ->
        render(conn, "address_search.html", %{order: order, address_list: []})

      address_list ->
        render(conn, "address_search.html", %{order: order, address_list: address_list})
    end
  end

  def address_attach(conn, params) do
    order = load_order(%{number: params["order_number"]})
    address_id = String.to_integer(params["address_id"])

    address =
      Repo.get(Address, address_id)
      |> Map.from_struct()
      |> Map.drop([:__meta])

    context =
      order
      |> Context.new(
        state: %{
          billing_address: address,
          shipping_address: address
        }
      )

    transition = DefaultMachine.add_addresses(context)

    case transition.valid? do
      true ->
        redirect(conn, to: order_path(conn, :show, order.id))

      false ->
        conn = put_flash(conn, :error, transition.errors[:error])
        redirect(conn, to: "/orders/#{order.number}/address/search")
    end
  end

  def address_add(conn, params) do
    order = load_order(%{number: params["order_number"]})

    changeset = Address.changeset(%Address{}, params["address"])

    case changeset.valid? do
      true ->
        {:ok, address} = Repo.insert(changeset)
        redirect(conn, to: "/orders/#{order.number}/address/search")

      false ->
        [error_text | _] = changeset.errors
        {title, {error_value, _}} = error_text
        conn = put_flash(conn, :error, Atom.to_string(title) <> " - " <> error_value)
        redirect(conn, to: "/orders/#{order.number}/address/add")
    end
  end

  defp remove_line_item(edit_item, line_items) do
    line_items
    |> Enum.reject(fn %{id: id} -> id == String.to_integer(edit_item) end)
    |> Enum.map(fn item -> Map.from_struct(item) |> Map.drop([:__meta]) end)
  end

  defp fetch_line_item(edit_item, line_items) do
    line_items
    |> Enum.reject(fn %{id: id} -> id != String.to_integer(edit_item) end)
  end

  defp struct_to_map(items) do
    Enum.map(items, fn item -> Map.from_struct(item) |> Map.drop([:__meta]) end)
  end

  defp search_item_variant(search) do
    query =
      from(
        u in Variant,
        where: ilike(u.sku, ^"%#{search}%")
      )

    Repo.all(query)
  end

  defp search_address_list(search) do
    query =
      from(
        u in Address,
        where: ilike(u.first_name, ^"%#{search}%")
      )

    Repo.all(query)
  end

  defp load_order(order) do
    order
    |> Order.get()
    |> Repo.preload(line_items: [:variant])
  end
end
