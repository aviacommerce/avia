defmodule AdminApp.OrderContext do
  @moduledoc """
  Module for the order related helper functions
  """
  import Ecto.Query

  alias AdminAppWeb.Helpers
  alias BeepBop.Context
  alias Snitch.Domain.Order.DefaultMachine
  alias Snitch.Data.Schema.{Order, Package}
  alias Snitch.Data.Model.Order, as: OrderModel
  alias Snitch.Core.Tools.MultiTenancy.Repo
  alias Snitch.Domain.Order, as: OrderDomain
  alias SnitchPayments.PaymentMethodCode
  alias Snitch.Data.Model.Payment
  alias AdminApp.Order.SearchContext
  alias Snitch.Pagination

  def get_order(%{"number" => number}) do
    case OrderModel.get(%{number: number}) do
      {:ok, order} ->
        order =
          Repo.preload(order, [
            [line_items: :product],
            [packages: [:items, :shipping_method]],
            [payments: :payment_method],
            :user
          ])

        {:ok, order}

      {:error, msg} ->
        {:error, msg}
    end
  end

  def get_order(%{"id" => id}) do
    {:ok, order} = id |> String.to_integer() |> OrderModel.get()

    case OrderModel.get(String.to_integer(id)) do
      {:ok, order} ->
        order =
          Repo.preload(order, [
            [line_items: :product],
            [packages: [:items, :shipping_method]],
            [payments: :payment_method],
            :user
          ])

        {:ok, order}

      {:error, msg} ->
        {:error, msg}
    end
  end

  def get_total(order) do
    OrderDomain.total_amount(order)
  end

  def order_list("pending", sort_param, page) do
    rummage = get_rummage(sort_param)
    query = query_confirmed_orders(rummage)
    orders = load_orders(query)

    orders_query =
      from(order in orders,
        left_join: package in Package,
        on: order.id == package.order_id,
        where: package.state == ^:processing
      )

    Pagination.page(orders_query, page)
  end

  def order_list("unshipped", sort_param, page) do
    rummage = get_rummage(sort_param)
    query = query_confirmed_orders(rummage)
    orders = load_orders(query)

    orders_query =
      from(order in orders,
        left_join: package in Package,
        on: order.id == package.order_id,
        where: package.state == ^:ready
      )

    Pagination.page(orders_query, page)
  end

  def order_list("shipped", sort_param, page) do
    rummage = get_rummage(sort_param)
    query = query_confirmed_orders(rummage)
    orders = load_orders(query)

    orders_query =
      from(order in orders,
        left_join: package in Package,
        on: order.id == package.order_id,
        where: package.state == ^:shipped or package.state == ^:delivered
      )

    Pagination.page(orders_query, page)
  end

  def update_cod_payment(order, state) do
    order = Repo.preload(order, :payments)

    cod_payment =
      Enum.find(order.payments, fn payment ->
        payment.payment_type == PaymentMethodCode.cash_on_delivery()
      end)

    Payment.update(cod_payment, %{state: state})
  end

  def state_transition(_state = "complete", order) do
    order
    |> Context.new()
    |> DefaultMachine.complete_order()
    |> transition_response()
  end

  defp transition_response(%Context{errors: nil}) do
    {:ok, "Order moved to Completed"}
  end

  defp transition_response(%Context{errors: errors}) do
    errors =
      Enum.reduce(errors, "", fn {:error, message}, acc ->
        acc <> " " <> message
      end)

    {:error, errors}
  end

  defp initial_date_range do
    %{
      start_date:
        30
        |> Helpers.date_days_before()
        |> Date.from_iso8601()
        |> elem(1)
        |> SearchContext.format_date(),
      end_date: SearchContext.format_date(Date.utc_today())
    }
  end

  def order_list("complete", sort_param, page) do
    rummage = get_rummage(sort_param)
    {queryable, _rummage} = Order.rummage(rummage)

    query =
      from(p in queryable,
        where:
          p.state == "complete" and p.updated_at >= ^initial_date_range.start_date and
            p.updated_at <= ^initial_date_range.end_date
      )

    query
    |> load_orders()
    |> Pagination.page(page)
  end

  defp query_confirmed_orders(rummage) do
    {queryable, _rummage} = Order.rummage(rummage)

    query =
      from(p in queryable,
        where:
          p.state == "confirmed" and p.updated_at >= ^initial_date_range.start_date and
            p.updated_at <= ^initial_date_range.end_date,
        select: p
      )
  end

  defp get_rummage(sort_param) do
    case sort_param do
      nil ->
        %{}

      _ ->
        sort_order = String.to_atom(sort_param)

        %{
          sort: %{field: :inserted_at, order: sort_order}
        }
    end
  end

  defp load_orders(query) do
    preload(query, [:user, [packages: :items], [line_items: :product]])
  end
end
