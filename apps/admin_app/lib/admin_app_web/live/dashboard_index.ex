defmodule AdminAppWeb.DashboardIndex do
  use AdminAppWeb, :live_view

  alias Snitch.Data.Model
  alias AdminAppWeb.Helpers
  alias VegaLite, as: Vl

  def mount(params, session, socket) do
    if connected?(socket),
      do: IO.puts("Live Dashboard is connected")

    with {:ok, socket} <- prepare_assigns(session, socket) do
      {start_date, end_date} = get_date_from_params(params)

      {:ok,
       socket
       |> assign(:conn, socket)}
    else
      _ ->
        {:error, :not_authorized}
    end
  end

  def handle_params(params, _uri, socket) do
    {start_date, end_date} = get_date_from_params(params)
    IO.inspect(get_order_state_count(start_date, end_date))

    {:noreply,
     socket
     |> assign(:conn, socket)
     |> assign(:order_state_counts, get_order_state_count(start_date, end_date))
     |> assign(:product_state_counts, get_product_state_count())
     |> assign(
       :order_chart_spec,
       chart_spec(get_order_datapoints(start_date, end_date), "date", "orders")
     )
     |> assign(
       :payment_chart_spec,
       chart_spec(get_payment_datapoints(start_date, end_date), "date", "amount")
     )
     |> assign(:start_date, naive_date_to_string(start_date))
     |> assign(:end_date, naive_date_to_string(end_date))}
  end

  def render(assigns) do
    ~H"""
    <div class="container">
      <h2 class="pb-5">Dashboard</h2>
      <div class="flex justify-end">
        <.form class="group relative" let={f} for={:date_range}>
          <label>from : </label>
          <%= text_input f, :start_date, type: "date", value: @start_date, phx_change: "update-start-date", class: "border-0" %>
          <%= text_input f, :end_date, type: "date", value: @end_date, phx_change: "update-end-date", class: "border-0" %>
        </.form>
      </div>
      <hr />
      <div class="flex flex-col py-5">
        <%= if @order_state_counts != [] do %> 
          <div class="pb-5">
            <h3 class="font-medium">Order stats</h3>
            <hr />
            <%= for %{state: state, count: count} <- @order_state_counts do %>
              <%= "#{state} : #{count}" %>
            <% end %>
          </div>
        <% end %>
        <%= if @product_state_counts != [] do %> 
          <div>
            <h3 class="font-medium">Product stats</h3>
            <hr />
            <%= for %{state: state, count: count} <- @product_state_counts do %>
              <%= "#{state} : #{count}" %>
            <% end %>
          </div>
        <% end %>
      </div>
      <div class="flex">
        <.live_component module={AdminAppWeb.VegaLiteComponent}
          id="vega-chart-orders"
          spec={@order_chart_spec}
        />
        <.live_component module={AdminAppWeb.VegaLiteComponent}
          id="vega-chart-payments"
          spec={@payment_chart_spec}
        />
      </div>
    </div>
    """
  end

  def handle_event("update-start-date", %{"date_range" => %{"start_date" => start_date}}, socket) do
    {:noreply,
     push_patch(socket,
       to:
         Routes.live_path(socket, AdminAppWeb.DashboardIndex, %{
           from: start_date,
           to: socket.assigns.end_date
         })
     )}
  end

  def handle_event("update-end-date", %{"date_range" => %{"end_date" => end_date}}, socket) do
    {:noreply,
     push_patch(socket,
       to:
         Routes.live_path(socket, AdminAppWeb.DashboardIndex, %{
           from: socket.assigns.start_date,
           to: end_date
         })
     )}
  end

  defp chart_spec(data, x_name, y_name) do
    Vl.new(width: 400, height: 200)
    |> Vl.data_from_values(data)
    |> Vl.mark(:bar)
    |> Vl.encode_field(:x, x_name, type: :nominal)
    |> Vl.encode_field(:y, y_name, type: :quantitative)
    |> Vl.to_spec()
  end

  defp naive_date_to_string(date) do
    date |> NaiveDateTime.to_date() |> Date.to_string()
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

  defp get_date_from_params(params) do
    default_start_date = Helpers.date_days_before(30) |> Date.from_iso8601() |> elem(1)

    start_date =
      params |> Map.get("from") |> get_naive_date_time(~T[00:00:00], default_start_date)

    end_date = params |> Map.get("to") |> get_naive_date_time(~T[23:59:59])

    {start_date, end_date}
  end

  defp get_order_state_count(start_date, end_date) do
    Model.Order.get_order_count_by_state(start_date, end_date)
  end

  defp get_product_state_count() do
    Model.Product.get_product_count_by_state()
  end

  @spec get_order_datapoints(any(), any()) :: %{data: any(), labels: any()}
  defp get_order_datapoints(start_date, end_date) do
    start_date
    |> Model.Order.get_order_count_by_date(end_date)
    |> Enum.map(&%{date: &1.date, orders: &1.count})
  end

  defp get_payment_datapoints(start_date, end_date) do
    start_date
    |> Model.Payment.get_payment_count_by_date(end_date)
    |> Enum.map(&%{date: &1.date, amount: get_amount(&1.count)})
  end

  defp only_key(data, key) do
    data |> Enum.into([], fn x -> x |> Map.get(key) end)
  end

  defp format_response(data) do
    Enum.map(data, &%{date: &1.date, orders: &1.count})
  end

  defp format_payment_response(data) do
  end

  defp get_amount(money) do
    money.amount
    |> Decimal.to_string(:normal)
    |> Decimal.round(2)
  end

  defp get_currency_value(money) do
    money.currency |> to_string
  end
end
