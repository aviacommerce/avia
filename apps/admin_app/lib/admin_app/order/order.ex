defmodule AdminApp.OrderContext do
  import Ecto.Query

  alias BeepBop.Context
  alias Snitch.Domain.Order.DefaultMachine
  alias Snitch.Data.Schema.Order
  alias Snitch.Data.Model.Order, as: OrderModel
  alias Snitch.Core.Tools.MultiTenancy.Repo
  alias Snitch.Domain.Order, as: OrderDomain
  alias SnitchPayments.PaymentMethodCode
  alias Snitch.Data.Model.Payment

  def get_order(%{"number" => number}) do
    %{number: number}
    |> OrderModel.get()
    |> Repo.preload([
      [line_items: :product],
      [packages: [:items, :shipping_method]],
      [payments: :payment_method],
      :user
    ])
  end

  def get_order(%{"id" => id}) do
    id
    |> String.to_integer()
    |> OrderModel.get()
    |> Repo.preload([
      [line_items: :product],
      [packages: [:items, :shipping_method]],
      [payments: :payment_method],
      :user
    ])
  end

  def get_total(order) do
    OrderDomain.total_amount(order)
  end

  def order_list("pending", sort_param) do
    rummage = get_rummage(sort_param)
    query = query_confirmed_orders(rummage)
    orders = load_orders(query)

    Enum.filter(orders, fn order ->
      Enum.any?(order.packages, fn package ->
        package.state == "processing"
      end)
    end)
  end

  def order_list("unshipped", sort_param) do
    rummage = get_rummage(sort_param)
    query = query_confirmed_orders(rummage)
    orders = load_orders(query)

    Enum.filter(orders, fn order ->
      Enum.any?(order.packages, fn package ->
        package.state == "ready"
      end)
    end)
  end

  def order_list("shipped", sort_param) do
    rummage = get_rummage(sort_param)
    query = query_confirmed_orders(rummage)
    orders = load_orders(query)

    Enum.filter(orders, fn order ->
      Enum.any?(order.packages, fn package ->
        package.state == "shipped" || package.state == "delivered"
      end)
    end)
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

  def order_list("complete", sort_param) do
    rummage = get_rummage(sort_param)
    {queryable, _rummage} = Order.rummage(rummage)
    query = from(p in queryable, where: p.state == "complete")
    load_orders(query)
  end

  defp query_confirmed_orders(rummage) do
    {queryable, _rummage} = Order.rummage(rummage)
    query = from(p in queryable, where: p.state == "confirmed", select: p)
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
    Repo.all(query) |> Repo.preload([:user, :packages, [line_items: :product]])
  end
end
