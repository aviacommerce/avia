defmodule AdminAppWeb.Helpers do
  import Ecto.Changeset
  import Ecto.Query
  alias Ecto.Adapters.SQL
  alias Snitch.Core.Tools.MultiTenancy.Repo
  alias Snitch.Data.Schema.Order
  alias Snitch.Domain.Order, as: Domain
  alias Elixlsx.{Workbook, Sheet}
  alias AdminAppWeb.DataExportMail

  @months ["Jan", "Feb", "Mar", "Apr", "May", "June", "July", "Aug", "Sept", "Oct", "Nov", "Dec"]

  def extract_changeset_data(changeset) do
    if changeset.valid?() do
      {:ok, Params.data(changeset)}
    else
      {:error, changeset}
    end
  end

  def extract_changeset_errors(changeset) do
    traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end

  @doc """
  Return the date in the format:
    HH:MIN, DAY, DATE, MONTH, YEAR
  """
  @spec format_date(NaiveDateTime.t()) :: String.t()
  def format_date(date) do
    to_string(date.hour) <>
      ":" <>
      to_string(date.minute) <>
      ", " <> to_string(date.day) <> " " <> month_name(date.month) <> ", " <> to_string(date.year)
  end

  def month_name(month_number) when month_number in 1..12 do
    Enum.at(@months, month_number - 1)
  end

  @doc """
  Return the date in the params with the key or returns
  date of the day as recived from Date.utc_today(calendar \\ Calendar.ISO) in
  string format.
  """
  @spec get_date_from_params(map(), any()) :: any()
  def get_date_from_params(params, key) do
    today = Date.utc_today() |> Date.to_string()
    select_date(today, Map.get(params, key))
  end

  defp select_date(today, nil), do: today

  defp select_date(today, ""), do: today

  defp select_date(_today, date_from_params), do: date_from_params

  def date_today() do
    Date.utc_today()
    |> Date.to_string()
  end

  def date_days_before(days) do
    Date.utc_today()
    |> Date.add(-1 * days)
    |> Date.to_string()
  end

  def order_csv_exporter(user) do
    path = "/tmp/orders.csv"
    query = from(u in Order, preload: [:line_items])

    columns =
      ~w(id number line_items_count order_total billing_address shipping_address inserted_at updated_at user_id state)a

    {:ok, file} =
      Repo.transaction(fn ->
        query
        |> Repo.stream()
        |> Stream.map(&parse_line/1)
        |> CSV.encode(headers: columns, separator: ?\t, delimiter: "\n")
        |> Enum.into(File.stream!(path, [:write, :utf8]))
      end)

    attachment = %Plug.Upload{
      path: file.path,
      content_type: "text/csv",
      filename: "orders.csv"
    }

    DataExportMail.data_export_mail(attachment, user, "csv")
  end

  defp parse_line(order) do
    order
    |> Map.from_struct()
    |> parse_address()
    |> Map.put(:line_items_count, Domain.line_items_count(order))
    |> Map.put(:order_total, Domain.total_amount(order))
  end

  defp parse_address(order) do
    shipping_address = order.shipping_address |> format_address
    billing_address = order.billing_address |> format_address
    %{order | shipping_address: shipping_address, billing_address: billing_address}
  end

  defp format_address(address) do
    case address do
      nil ->
        nil

      address ->
        address
        |> Map.from_struct()
        |> Enum.map(fn {key, value} -> value end)
        |> Enum.join(" ")
    end
  end

  def order_xlsx_exporter(user) do
    orders = Repo.all(Order) |> Repo.preload([:line_items])

    xlsx_generator(orders)
    |> Elixlsx.write_to("/tmp/order.xlsx")

    attachment = "/tmp/order.xlsx"

    DataExportMail.data_export_mail(attachment, user, "xlsx")
  end

  def xlsx_generator(orders) do
    columns =
      ~w(id number line_items_count order_total billing_address shipping_address inserted_at updated_at user_id state)

    orders = orders |> Enum.map(&parse_line(&1))
    rows = orders |> Enum.map(&row(&1))
    %Workbook{sheets: [%Sheet{name: "Orders", rows: [columns] ++ rows}]}
  end

  def row(order) do
    columns =
      ~w(id number line_items_count order_total billing_address shipping_address inserted_at updated_at user_id state)

    Enum.map(columns, &(Map.get(order, :"#{&1}") |> to_string))
  end
end
