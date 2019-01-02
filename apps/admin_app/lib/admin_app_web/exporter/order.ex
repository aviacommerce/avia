defmodule AdminAppWeb.Exporter.Order do
  @moduledoc """
  Data export module for Order.
  """
  alias AdminAppWeb.Exporter
  import Ecto.Query
  alias Snitch.Domain.Order, as: Domain
  alias Snitch.Data.Schema.Order
  alias Snitch.Data.Model.Order, as: OrderModel

  @columns ~w(id number line_items_count order_total billing_address shipping_address inserted_at updated_at user_id state)a
  @preloads ~w(line_items)a

  def csv_exporter(user) do
    query = from(u in Order, preload: ^@preloads)
    Exporter.csv_exporter(user, "order", query, @columns)
  end

  def xlsx_exporter(user) do
    data_list = OrderModel.get_all_with_preloads(@preloads)
    Exporter.xlsx_exporter(user, "order", data_list, @columns)
  end

  def parse_line(%Order{} = order) do
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
end
