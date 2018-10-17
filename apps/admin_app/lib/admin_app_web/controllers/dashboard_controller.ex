defmodule AdminAppWeb.DashboardController do
  use AdminAppWeb, :controller

  alias Snitch.Data.Model
  alias AdminAppWeb.Helpers

  def index(conn, params) do
    {start_date, end_date} = get_date_from_params(params)

    conn
    |> assign(:order_state_counts, get_order_state_count(start_date, end_date))
    |> assign(:product_state_counts, get_product_state_count(start_date, end_date))
    |> assign(:order_datepoints, get_order_datapoints(start_date, end_date))
    |> assign(:payment_datapoints, get_payment_datapoints(start_date, end_date))
    |> render("index.html")
  end

  defp get_naive_date_time(date) do
    Date.from_iso8601(date)
    |> elem(1)
    |> NaiveDateTime.new(~T[00:00:00])
    |> elem(1)
  end

  defp get_date_from_params(params) do
    start_date = Helpers.get_date_from_params(params, "from") |> get_naive_date_time()

    end_date = Helpers.get_date_from_params(params, "to") |> get_naive_date_time()

    {start_date, end_date}
  end

  defp get_order_state_count(start_date, end_date) do
    Model.Order.get_order_count_by_state(start_date, end_date)
  end

  defp get_product_state_count(start_date, end_date) do
    Model.Product.get_product_count_by_state(start_date, end_date)
  end

  @spec get_order_datapoints(any(), any()) :: %{data: any(), labels: any()}
  defp get_order_datapoints(start_date, end_date) do
    format_response(Model.Order.get_order_count_by_date(start_date, end_date))
  end

  defp get_payment_datapoints(start_date, end_date) do
    format_payment_response(Model.Payment.get_payment_count_by_date(start_date, end_date))
  end

  defp only_key(data, key) do
    data |> Enum.into([], fn x -> x |> Map.get(key) end)
  end

  defp format_response(data) do
    %{
      labels: only_key(data, :date),
      data: only_key(data, :count)
    }
  end

  defp format_payment_response(data) do
    %{
      labels: only_key(data, :date),
      data: only_key(data, :count) |> Enum.into([], fn x -> get_amount(x) end),
      currency: only_key(data, :count) |> Enum.into([], fn x -> get_currency_value(x) end)
    }
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
