defmodule AdminApp.OrderContext do
  import Ecto.Query
  alias Snitch.Data.Schema.Order
  alias Snitch.Data.Model.Order, as: OrderModel
  alias Snitch.Repo

  def get_order(%{"number" => number}) do
    %{number: number}
    |> OrderModel.get()
    |> Repo.preload([[line_items: :product], :packages, :payments, :user])
  end

  def order_list("pending") do
    query = query_confirmed_orders()
    orders = load_orders(query)

    Enum.filter(orders, fn order ->
      Enum.any?(order.packages, fn package ->
        package.state == "processing"
      end)
    end)
  end

  def order_list("unshipped") do
    query = query_confirmed_orders()
    orders = load_orders(query)

    Enum.filter(orders, fn order ->
      Enum.any?(order.packages, fn package ->
        package.state == "ready"
      end)
    end)
  end

  def order_list("unshipped") do
    query = query_confirmed_orders()
    orders = load_orders(query)

    Enum.filter(orders, fn order ->
      Enum.any?(order.packages, fn package ->
        package.state == "shipped"
      end)
    end)
  end

  def order_list("complete") do
    query =
      from(
        order in Order,
        where: order.state == "complete"
      )

    orders = Repo.all(Order, query)
  end

  defp query_confirmed_orders() do
    from(
      order in Order,
      where: order.state == "confirmed",
      select: order
    )
  end

  defp load_orders(query) do
    Repo.all(query) |> Repo.preload([:user, :packages, [line_items: :product]])
  end
end
