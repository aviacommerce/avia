defmodule AdminAppWeb.OrderController do
  use AdminAppWeb, :controller

  import Ecto.Query
  import Phoenix.View, only: [render_to_string: 3]

  alias Snitch.Data.Model.Order
  alias BeepBop.Context
  alias Snitch.Domain.Order.DefaultMachine
  alias Snitch.Data.Schema.{Address, Product}
  alias Snitch.Repo
  alias AdminAppWeb.OrderView
  alias AdminApp.OrderContext
  alias AdminApp.PackageContext

  @root_path [File.cwd!(), "invoices"] |> Path.join()

  def index(conn, %{"category" => category}) do
    orders = OrderContext.order_list(category)
    token = get_csrf_token()

    html =
      render_to_string(
        OrderView,
        "order_listing.html",
        orders: orders,
        token: token
      )

    conn
    |> put_status(200)
    |> json(%{html: html})
  end

  def index(conn, _params) do
    render(conn, "index.html", %{
      orders: OrderContext.order_list("pending"),
      token: get_csrf_token()
    })
  end

  def show(conn, %{"number" => _number} = params) do
    order = OrderContext.get_order(params)
    order_total = OrderContext.get_total(order)

    render(
      conn,
      "show.html",
      order: order,
      order_total: order_total
    )
  end

  def update_package(conn, %{"id" => id, "state" => state}) do
    order = OrderContext.get_order(%{"id" => id})

    case PackageContext.update_packages(state, String.to_integer(id)) do
      {:ok, _} ->
        order_total = OrderContext.get_total(order)

        conn
        |> put_flash(:info, "Order Updated!")
        |> render("show.html", order: order, order_total: order_total)

      {:error, _} ->
        put_flash(conn, :error, "update failed!")
        redirect(conn, to: order_path(conn, :show, order.number))
    end
  end

  def update_state(conn, %{"id" => id, "state" => state}) do
    order = OrderContext.get_order(%{"id" => id})

    case OrderContext.state_transition(state, order) do
      {:ok, message} ->
        conn
        |> put_flash(:info, message)
        |> redirect(to: order_path(conn, :show, order.number))

      {:error, message} ->
        conn
        |> put_flash(:error, message)
        |> redirect(to: order_path(conn, :show, order.number))
    end
  end

  def cod_payment_update(conn, %{"id" => id, "state" => state}) do
    order = OrderContext.get_order(%{"id" => id})

    case OrderContext.update_cod_payment(order, state) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Order Payment marked as #{state}")
        |> redirect(to: order_path(conn, :show, order.number))

      {:error, _} ->
        conn
        |> put_flash(:error, "Update failed!")
        |> redirect(to: order_path(conn, :show, order.number))
    end
  end

  def create(conn, _params) do
    current_user = Guardian.Plug.current_resource(conn)
    {:ok, order} = Order.create(%{line_items: [], user_id: current_user.id})

    redirect(conn, to: order_path(conn, :show, order.id))
  end

  def show_invoice(conn, params) do
    order =
      load_order(%{number: params["number"]})
      |> Repo.preload([:line_items, :user])

    render(conn, "invoice.html", %{order: order})
  end

  def show_packing_slip(conn, params) do
    order = load_order(%{number: params["number"]})

    render(conn, "packing_slip.html", %{order: order})
  end

  def download_invoice_pdf(conn, params) do
    order = load_order(%{number: params["number"]})
    download_pdf_response(conn, order, "invoice", params)
  end

  def download_packing_slip_pdf(conn, params) do
    order = load_order(%{number: params["number"]})
    download_pdf_response(conn, order, "packing_slip", params)
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

    product_id = String.to_integer(params["add"])
    quantity = String.to_integer(params["quantity"])
    add_line_item = %{quantity: quantity, product_id: product_id}
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
        u in Product,
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
    |> Repo.preload([
      [line_items: :product],
      [packages: [:items, :shipping_method]],
      :payments,
      :user
    ])
  end

  defp download_pdf_response(conn, order, type, params) do
    case generate_pdf(order, type) do
      {:ok, :ok} ->
        send_file_response(
          conn,
          params,
          @root_path |> Path.join("#{type}_#{params["number"]}.pdf"),
          type
        )

      {:ok, {:error, reason}} ->
        send_pdf_response(conn, params, {:error, reason |> format_error()}, type)

      {:error, message} ->
        send_pdf_response(conn, params, {:error, message}, type)
    end
  end

  defp send_file_response(conn, params, path, type) do
    case read_file(path) do
      {:ok, file} ->
        send_pdf_response(conn, params, {:ok, file}, type)

      {:error, reason} ->
        send_pdf_response(conn, params, {:error, reason |> format_error()}, type)
    end
  end

  defp send_pdf_response(conn, params, {:error, msg}, _type) do
    conn
    |> put_flash(:error, msg)
    |> redirect(to: "/orders/#{params["number"]}/detail")
  end

  defp send_pdf_response(conn, params, {:ok, data}, type) do
    conn
    |> put_resp_content_type("application/pdf")
    |> put_resp_header(
      "content-disposition",
      "attachment; filename=\"#{type}_#{params["number"]}.pdf\""
    )
    |> send_resp(200, data)
  end

  defp read_file(path) do
    File.read(path)
  end

  def write_file(order, file, type) do
    [@root_path, "#{type}_#{order.number}.pdf"]
    |> Path.join()
    |> Path.expand()
    |> File.write(file)
  end

  defp generate_pdf(order, type) do
    case generate_binary(order, type) do
      {true, file} -> {:ok, order |> write_file(file, type)}
      {false, _file} -> {:error, "Path resolution error!"}
      {:error, message} -> {:error, message}
    end
  end

  defp generate_binary(order, type) do
    case get_pdf_binary(order, type) do
      {:ok, file} ->
        {resolve_dir_path(), file}

      _ ->
        {:error, "Error while generating binary!"}
    end
  end

  def get_pdf_binary(order, type) do
    case type do
      "invoice" ->
        OrderView
        |> render_to_string("invoice.html", order: order)
        |> PdfGenerator.generate_binary(page_size: "A4")

      "packing_slip" ->
        OrderView
        |> render_to_string("packing_slip.html", order: order)
        |> PdfGenerator.generate_binary(page_size: "A4")
    end
  end

  defp resolve_dir_path() do
    (@root_path |> File.dir?() || @root_path |> File.mkdir_p()) in [:ok, true]
  end

  defp format_error(error), do: :file.format_error(error)
end
