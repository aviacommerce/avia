defmodule AdminApp.Order.SearchContext do
  @moduledoc """
  Helper functions for order search on the basis of:
  - Customer first_name, last_name or email
  - Order state
  - Order number
  - Date range for order placed
  """
  import Ecto.Query
  alias Snitch.Data.Schema.{Order, User}
  alias Snitch.Core.Tools.MultiTenancy.Repo
  alias Snitch.Pagination

  @order_preloads [:user, [packages: [:shipping_method, :items]], [line_items: :product]]

  def search_orders(%{"term" => term} = payload) do
    state = get_order_state(term)
    page = payload["page"] || 1

    user_ids =
      User
      |> where(
        [user],
        ilike(user.first_name, ^"%#{term}%") or ilike(user.last_name, ^"%#{term}%") or
          ilike(user.email, ^"%#{term}%")
      )
      |> select([user], user.id)
      |> Repo.all()

    query =
      user_ids
      |> get_orders_with_state(term, state)
      |> preload(^@order_preloads)
      |> Pagination.page(page)
  end

  def search_orders(
        %{
          "start_date" => start_date,
          "end_date" => end_date
        } = payload
      ) do
    start_date = format_date(start_date)
    end_date = format_date(end_date)
    page = payload["page"] || 1

    Order
    |> where([o], o.updated_at >= ^start_date and o.updated_at <= ^end_date)
    |> preload(^@order_preloads)
    |> Pagination.page(page)
  end

  def format_date(date) do
    NaiveDateTime.from_iso8601!("#{date} 00:00:00")
  end

  defp get_order_state(term) do
    case OrderStateEnum.valid_value?(term) do
      true ->
        term

      false ->
        "invalid"
    end
  end

  defp get_orders_with_state(user_ids, term, "invalid") do
    from(o in Order,
      where: o.user_id in ^user_ids or ilike(o.number, ^"%#{term}%")
    )
  end

  defp get_orders_with_state(user_ids, term, valid_state) do
    from(o in Order,
      where: o.user_id in ^user_ids or ilike(o.number, ^"%#{term}%") or o.state == ^valid_state
    )
  end
end
