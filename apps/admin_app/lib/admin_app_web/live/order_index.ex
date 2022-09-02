defmodule AdminAppWeb.Live.OrderIndex do
  use AdminAppWeb, :live_view

  alias AdminApp.OrderContext
  alias AdminAppWeb.Helpers
  import AdminAppWeb.Live.DataTable

  def mount(params, session, socket) do
    if connected?(socket),
      do: IO.puts("Order Index is connected")

    prepare_assigns(session, socket)
  end

  def handle_params(params, _uri, socket) do
    {start_date, end_date} = get_date_from_params(params)
    page = params["page"] || 1
    orders = OrderContext.order_list("pending", sort(params), page, {start_date, end_date})

    {:noreply,
     socket
     |> assign(:end_date, naive_date_to_string(end_date))
     |> assign(:start_date, naive_date_to_string(start_date))
     |> assign(:conn, socket)
     |> assign(:params, params)
     |> assign(:orders, orders)}
  end

  def render(assigns) do
    ~H"""
    <div class="container">
      <h2 class="pb-5">Orders</h2>
      <div class="flex justify-end">
        <.form class="group relative" let={f} for={:date_range}>
          <label>from : </label>
          <%= text_input f, :start_date, type: "date", value: @start_date, phx_change: "update-start-date", class: "border-0" %>
          <label>to : </label>
          <%= text_input f, :end_date, type: "date", value: @end_date, phx_change: "update-end-date", class: "border-0" %>
        </.form>
      </div>
      <hr />
      <div class="flex w-full">
        <.live_component module={AdminAppWeb.OrderListComponent} id="orders-list" params={@params} orders={@orders} />
      </div>
    </div>
    """
  end

  def handle_event("update-start-date", %{"date_range" => %{"start_date" => start_date}}, socket) do
    {:noreply,
     push_patch(socket,
       to:
         Routes.live_path(socket, AdminAppWeb.Live.OrderIndex, %{
           from: start_date,
           to: socket.assigns.end_date
         })
     )}
  end

  def handle_event("update-end-date", %{"date_range" => %{"end_date" => end_date}}, socket) do
    {:noreply,
     push_patch(socket,
       to:
         Routes.live_path(socket, AdminAppWeb.Live.OrderIndex, %{
           from: socket.assigns.start_date,
           to: end_date
         })
     )}
  end

  defp naive_date_to_string(date) do
    date |> NaiveDateTime.to_date() |> Date.to_string()
  end

  defp get_date_from_params(params) do
    default_start_date = Helpers.date_days_before(30) |> Date.from_iso8601() |> elem(1)

    start_date =
      params |> Map.get("from") |> get_naive_date_time(~T[00:00:00], default_start_date)

    end_date = params |> Map.get("to") |> get_naive_date_time(~T[23:59:59])

    {start_date, end_date}
  end

  defp get_naive_date_time(date, time, default_date \\ Date.utc_today())

  defp get_naive_date_time(nil, time, default_date) do
    default_date
    |> NaiveDateTime.new(time)
    |> elem(1)
  end

  defp get_naive_date_time(date, time, default_date) do
    valid_date =
      case Date.from_iso8601(date) do
        {:ok, date} ->
          date

        {:error, _} ->
          default_date
      end

    valid_date
    |> NaiveDateTime.new(time)
    |> elem(1)
  end
end
