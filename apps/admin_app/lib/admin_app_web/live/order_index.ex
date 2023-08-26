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
    search_term = Map.get(params, :search_term, "")
    orders = OrderContext.order_list("pending", sort(params), page, {start_date, end_date})

    {:noreply,
     socket
     |> assign(:end_date, naive_date_to_string(end_date))
     |> assign(:start_date, naive_date_to_string(start_date))
     |> assign(:search_term, search_term)
     |> assign(:conn, socket)
     |> assign(:params, params)
     |> assign(:orders, orders)}
  end

  def render(assigns) do
    ~H"""
    <div class="container">
      <h2 class="pb-5">Orders</h2>
      <div class="flex pb-4 justify-between">
        <div class="bg-white dark:bg-gray-900">
          <label for="order-search" class="sr-only">Search</label>
          <div class="relative mt-1">
            <div class="flex absolute inset-y-0 left-0 items-center pl-3 pointer-events-none">
              <svg class="w-5 h-5 text-gray-500 dark:text-gray-400" aria-hidden="true" fill="currentColor" viewBox="0 0 20 20" xmlns="http://www.w3.org/2000/svg"><path fill-rule="evenodd" d="M8 4a4 4 0 100 8 4 4 0 000-8zM2 8a6 6 0 1110.89 3.476l4.817 4.817a1 1 0 01-1.414 1.414l-4.816-4.816A6 6 0 012 8z" clip-rule="evenodd"></path></svg>
            </div>
            <.form :let={f} for={%{}} as={:orders}>
              <%= text_input f, :search_term, id: "order-search", placeholder: "Search for orders", value: @search_term, phx_change: "update-search-term", class: "block p-2 pl-10 w-80 text-sm text-gray-900 bg-gray-50 rounded-lg border border-gray-300 focus:ring-blue-500 focus:border-blue-500 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500" %>
            </.form>  
          </div>
        </div>
        <.form class="shadow-sm pl-4" :let={f} for={%{}} as={:date_range}>
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

  def handle_event("update-search-term", %{"orders" => %{"search_term" => search_term}}, socket) do
    {:noreply,
     push_patch(socket,
       to:
         Routes.live_path(socket, AdminAppWeb.Live.OrderIndex, %{
           search_term: search_term,
           from: socket.assigns.start_date,
           to: socket.assigns.end_date
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
