defmodule AdminAppWeb.Helpers do
  import Ecto.Changeset
  import Ecto.Query
  alias Ecto.Adapters.SQL
  alias Snitch.Core.Tools.MultiTenancy.Repo
  alias Snitch.Data.Schema.Order
  alias Elixlsx.{Workbook, Sheet}
  alias AdminAppWeb.OrderExportMail

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

  def order_csv_exporter() do

    path = "/tmp/orders.csv"
    query = from u in Order
    {:ok, file} = Repo.transaction fn ->
      query
      |> Repo.stream
      |> Stream.map(&parse_line/1)
      |> CSV.encode
      |> Enum.into(File.stream!(path, [:write, :utf8]))
    end
    attachment = %Plug.Upload{
      path: file.path,
      content_type: "text/csv",
      filename: "orders.csv"
    }
    OrderExportMail.order_export_mail(attachment, "csv")
  end

   defp parse_line(order) do
    # order our data to match our column order
    columns = ~w(id number special_instructions inserted_at updated_at user_id state)
    Enum.map(columns, &Map.get(order, :"#{&1}"))
  end

  def order_xlsx_exporter() do
    orders = Repo.all(Order)
    xlsx_generator(orders)
    |> Elixlsx.write_to_memory("/tmp/orders.xlsx") 
    |> elem(1) 
    |> elem(1)
    attachment = %Plug.Upload{
      path: "/tmp/orders.xlsx",
      content_type: "text/xlsx",
      filename: "orders.xlsx"
    }
    OrderExportMail.order_export_mail(attachment, "xlsx")
  end

  def xlsx_generator(orders) do
    columns = ~w(id number special_instructions inserted_at updated_at user_id state)
    rows = orders |> Enum.map(&(row(&1)))
    %Workbook{sheets: [%Sheet{name: "Orders", rows: [columns] ++ rows}]}
  end

  def row(order) do
    columns = ~w(id number special_instructions inserted_at updated_at user_id state)
    Enum.map(columns, &Map.get(order, :"#{&1}") |> to_string)
  end

end
