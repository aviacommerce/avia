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

  def order_list(state, sort_param, page, date_params) when is_nil(date_params),
    do:
      order_list(
        state,
        sort_param,
        page,
        {initial_date_range.start_date, initial_date_range.end_date}
      )

  def order_list(state, sort_param, page, {start_date, end_date}) do
    sort_param
    |> get_rummage()
    |> query_confirmed_orders({start_date, end_date})
    |> OrderModel.with_package_states_query(OrderModel.order_package_state_map()[state])
    |> order_preloads()
    |> Pagination.page(page)
  end

  def order_list("complete", sort_param, page, {start_date, end_date}) do
    {queryable, _rummage} =
      sort_param
      |> get_rummage()
      |> Order.rummage()

    queryable
    |> OrderModel.with_states_query(["complete"])
    |> OrderModel.updated_between_query(start_date, end_date)
    |> order_preloads()
    |> Pagination.page(page)
  end

  defp query_confirmed_orders(rummage, {start_date, end_date}) do
    {queryable, _rummage} = Order.rummage(rummage)

    queryable
    |> OrderModel.with_states_query(["confirmed"])
    |> OrderModel.updated_between_query(start_date, end_date)
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

  defp order_preloads(query) do
    preload(query, [:user, [packages: :items], [line_items: :product]])
  end
end
