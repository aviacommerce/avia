defmodule AdminAppWeb.Exporter do
  @moduledoc """
  Data export module for Snitch.
  """

  alias AdminAppWeb.Exporter.Product, as: ProductEx
  alias AdminAppWeb.Exporter.Order, as: OrderEx
  alias Snitch.Domain.Order, as: Domain
  alias Snitch.Core.Tools.MultiTenancy.Repo
  alias Elixlsx.{Workbook, Sheet}
  alias Snitch.Data.Schema.{Order, Product}
  alias AdminAppWeb.DataExportMail

  defp get_columns(type) do
    case type do
      "order" ->
        ~w(id number line_items_count order_total billing_address shipping_address inserted_at updated_at user_id state)a

      "product" ->
        ~w(id name product_type slug state max_retail_price selling_price variant_count taxon_name weight height depth store theme_id is_active)a
    end
  end

  def csv_exporter(user, "order") do
    OrderEx.csv_exporter(user)
  end

  def csv_exporter(user, "product") do
    ProductEx.csv_exporter(user)
  end

  def csv_exporter(user, type, query, columns) do
    path = "/tmp/#{type}s.csv"

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
      filename: "#{type}s.csv"
    }

    DataExportMail.data_export_mail(attachment, user, "csv", type)
  end

  def xlsx_exporter(user, "order") do
    OrderEx.xlsx_exporter(user)
  end

  def xlsx_exporter(user, "product") do
    ProductEx.xlsx_exporter(user)
  end

  def xlsx_exporter(user, type, data_list) do
    binary_data =
      xlsx_generator(data_list, type)
      |> Elixlsx.write_to("/tmp/#{type}s.xlsx")

    attachment = "/tmp/#{type}s.xlsx"

    DataExportMail.data_export_mail(attachment, user, "xlsx", type)
  end

  def xlsx_generator(data_list, type) do
    columns = get_columns(type) |> Enum.map(&Atom.to_string(&1))

    rows =
      data_list
      |> Enum.map(&parse_line(&1))
      |> Enum.map(&row(&1, columns))

    %Workbook{sheets: [%Sheet{name: "Data for #{type}s", rows: [columns] ++ rows}]}
  end

  defp parse_line(%Order{} = order) do
    OrderEx.parse_line(order)
  end

  defp parse_line(%Product{} = product) do
    ProductEx.parse_line(product)
  end

  def row(data, columns) do
    Enum.map(columns, &(Map.get(data, :"#{&1}") |> to_string))
  end
end
