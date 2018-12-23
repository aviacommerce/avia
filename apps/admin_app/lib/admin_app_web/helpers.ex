defmodule AdminAppWeb.Helpers do
  import Ecto.Changeset
  import Ecto.Query
  alias Ecto.Adapters.SQL
  alias AdminAppWeb.ProductView
  alias Snitch.Core.Tools.MultiTenancy.Repo
  alias Snitch.Data.Schema.{Order, Product}
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

  defp get_columns(type) do
    case type do
      "order" ->
        ~w(id number line_items_count order_total billing_address shipping_address inserted_at updated_at user_id state)a

      "product" ->
        ~w(id name product_type slug state max_retail_price selling_price variant_count taxon_name weight height depth store theme_id is_active)a
    end
  end

  def csv_exporter(user, type) do
    path = "/tmp/#{type}s.csv"

    query =
      case type do
        "order" ->
          from(u in Order, preload: [:line_items])

        "product" ->
          from(u in Product,
            preload: [:variants, :taxon, :shipping_category, :options, :brand, :theme]
          )
      end

    {:ok, file} =
      Repo.transaction(fn ->
        query
        |> Repo.stream()
        |> Stream.map(&parse_line/1)
        |> CSV.encode(headers: get_columns(type), separator: ?\t, delimiter: "\n")
        |> Enum.into(File.stream!(path, [:write, :utf8]))
      end)

    attachment = %Plug.Upload{
      path: file.path,
      content_type: "text/csv",
      filename: "#{type}s.csv"
    }

    DataExportMail.data_export_mail(attachment, user, "csv", type)
  end

  defp parse_line(%Order{} = order) do
    order
    |> Map.from_struct()
    |> parse_address()
    |> Map.put(:line_items_count, Domain.line_items_count(order))
    |> Map.put(:order_total, Domain.total_amount(order))
  end

  defp get_product_type(product) do
    case ProductView.is_parent_product(to_string(product.id)) do
      true ->
        "variable"

      false ->
        if ProductView.is_child_product(product), do: "variant", else: "simple"
    end
  end

  defp parse_line(%Product{} = product) do
    product
    |> Map.from_struct()
    |> Map.put(:product_type, get_product_type(product))
    |> Map.put(:taxon_name, product.taxon.name)
    |> Map.put(:variant_count, length(product.variants))
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

  def xlsx_exporter(user, type) do
    data_list =
      case type do
        "order" ->
          Repo.all(Order) |> Repo.preload([:line_items])

        "product" ->
          Repo.all(Product)
          |> Repo.preload([:variants, :taxon, :shipping_category, :options, :brand, :theme])
      end

    binary_data =
      xlsx_generator(data_list, type)
      |> Elixlsx.write_to("/tmp/#{type}s.xlsx")

    attachment = "/tmp/#{type}s.xlsx"

    DataExportMail.data_export_mail(attachment, user, "xlsx", type)
  end

  def xlsx_generator(data_list, type) do
    columns = get_columns(type) |> Enum.map(&Atom.to_string(&1))

    data_list = data_list |> Enum.map(&parse_line(&1))
    rows = data_list |> Enum.map(&row(&1, columns))
    %Workbook{sheets: [%Sheet{name: "Data for #{type}s", rows: [columns] ++ rows}]}
  end

  def row(data, columns) do
    Enum.map(columns, &(Map.get(data, :"#{&1}") |> to_string))
  end
end
